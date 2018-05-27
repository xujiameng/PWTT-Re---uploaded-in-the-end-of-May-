function [heartRate,peak]  = detectionRR2(u,fs)
% Description:
% 该程序功能为：基于带通滤波的QRS检测器
% 程序原理及流程：
%     Step1:由自适应阈值对滤波后的ECG信号进行处理，选择出可能的R波。
%     Step2:对每一个可能的R波进行如下规则的判断
%        Rule1: 如果一个波峰距前一个较大波峰或后一个较大波峰小于196毫秒（306BPM）的话，则对该波峰进行忽略。
%        Rule2: 如果对一个可能的波峰来说，其原始信号如果不存在正斜率与负斜率，则这个可能的峰值被认为是基准线移位的结果
%        Rule3: 如果峰值大于检测阈值，则将其归类为QRS波群，否则将其归类为噪声。
%        Rule4: 如果在1.5个R-R间期内没有检测到QRS，则有一个大于检测阈值的一半的峰值，并且峰值跟随前面的检测至少360MS，将峰值归类为QRS复合体。

% inputs:
%  u : 经过带通滤波器滤波后的ECG信号
%  fs: 采样频率

% outputs:
%  heartRate: 心率 (搏/分)
%  peak     : R波峰值点位置

%Called By：
%	调用本函数的清单
%     ECG250:对ECG信号进行滤波并获取峰值位置信息

%V1.0：2018/5/22

    persistent FS QRSDelay
    if isempty(FS)
        FS = fs; % Hz, samples per second
        QRSDelay = zeros(size(u), 'like', u);
    end
    
    heartRate = uint16(zeros(size(u)));
    peak = zeros(size(u), 'like', u);    
    threshold = zeros(size(u), 'like', u);
    % Prevents detections of peaks smaller than 150 uV.
    MIN_PEAK_AMP = cast(0.3, 'like', u(1));
    mminpk=zeros(size(u), 'like', u);    
    

    for idx = 1:length(u) 
        % For a frame of input signal, process one sample at a time
        peak(idx) = findpeak(u(idx));
        if(idx>1)
%              MIN_PEAK_AMP(idx)=threshold(idx-1)+0.2;
             MIN_PEAK_AMP(idx) =mminpk(idx-1);
        end
       if(peak(idx) < MIN_PEAK_AMP(idx))
            peak(idx) = 0 ;
        end

        % returns adjusted peak
        [QRSDelay(idx), threshold(idx), peak(idx),mminpk(idx)] = qrs_det(peak(idx));
        if QRSDelay(idx) ~= 0
            % beat per min = samplesPerSec * 60sec/min / samples per beat_oneQRSDalay
            heartRate(idx) = int16(60 * FS / QRSDelay(idx));
        end

    end
end % function QRSDetection


function pk = findpeak(datum)
    % peak() takes a datum as input and returns a peak height
    % when the signal returns to half its peak height, or it has been
    % 95 ms since the peak height was detected.
    
    persistent maxPeak lastDatum timeSinceMax
    pk = cast(0,'like',datum);
    if isempty(maxPeak)
        maxPeak = cast(0,'like',datum);
        lastDatum = cast(0,'like',datum);
        timeSinceMax = uint16(0);
        return
    end
    
    if timeSinceMax > 0
        timeSinceMax(:) = timeSinceMax + 1;
    end
    
    if((datum > lastDatum) && (datum > maxPeak)) % rising slope
        maxPeak(:) = datum ;
        if(maxPeak > 2) % reset timeSinceMax 
            timeSinceMax(:) = 1 ;
        end
    elseif(datum < bitsra(maxPeak,1)) % middle of falling slope
        % Less than half the peak height
        pk(:) = maxPeak ;
        maxPeak(:) = 0 ;
        timeSinceMax(:) = 0 ;
    elseif(timeSinceMax > MS95)
        pk(:) = maxPeak ;
        maxPeak(:) = 0 ;
        timeSinceMax(:) = 0 ;
    end
    lastDatum = datum ;
end

function [QRSDelay,thisThreshold, pk,mminpk] = qrs_det(pk)
    
    persistent count 
    persistent qpkcnt
    persistent lastQRSDelay
    persistent threshold
    persistent preBlankCnt
    persistent tempPeak
    persistent initMax
    persistent sbpeak
    persistent sbcount
    persistent minpk
        
    if isempty(lastQRSDelay)
        count = int16(0);
        qpkcnt = int16(0);
        lastQRSDelay = int16(0);
        % EC13: QRS detector should not detect QRS complexes with 
        %  amplitudes of less than 0.15mV and 1mV QRS complexes with width
        %  less than 10ms (6000bpm)
        threshold = cast(0.3, 'like', pk);
        tempPeak = cast(0, 'like', pk);
        initMax = cast(0, 'like', pk);
        preBlankCnt = int16(0);
        sbpeak = cast(0, 'like', pk);
        sbcount = int16(MS1650);
        minpk=cast(0.3, 'like', pk);
    end
    
    % there can only be one QRS complex in any 196ms (306bpm) window
    if (pk==0) && (preBlankCnt==0)
        pk(:) = 0;
    elseif (pk==0) && (preBlankCnt~=0)
        % if we have held onto a peak for 196ms, pass it on for eval
        preBlankCnt = preBlankCnt - 1;
        if (preBlankCnt == 0)
            pk(:) = tempPeak;
        else
            pk(:) = 0;
        end        
    elseif (pk~=0) && (preBlankCnt==0)
        % if there has been no peak for 196ms, save this one and start
        % counting
        tempPeak = pk;
        preBlankCnt = MS196;
        pk(:) = 0;
    else % (pk~=0) &&  (preBlankCnt~=0)
        % if we were holding a peak, but this one is bigger,
        % save it and start counting to 196ms again
        if (pk > tempPeak)
            tempPeak = pk;
            preBlankCnt = MS196;
            pk(:) = 0;
        else
            preBlankCnt = preBlankCnt - 1;
            if (preBlankCnt == 0)
                pk(:) = tempPeak;
            else
                pk(:) = 0;
            end
        end
    end
    
    count(:) = count + 1;
    
    % Initialize the QRS peak buffer with the first eight 
    % local maximum peaks detected
    if qpkcnt < 8
        if pk > 0
           UPDATEQ = true;
           [threshold,minpk] = updateQN(pk, UPDATEQ);
           qpkcnt = qpkcnt + 1;
           if pk > initMax 
               initMax = pk;
           end
           if qpkcnt == 8
               count(:) = 0;
           end
           
        end
        
    else % qpkcnt >= 8
        
        if pk > threshold
            UPDATEQ = true;
             [threshold,minpk] = updateQN(pk, UPDATEQ);
            lastQRSDelay(:) = count;
            count(:) = 0;
            sbpeak(:) = 0;
        elseif pk ~= 0
            % if peak is below threshold
            UPDATEQ = false;
             [threshold,minpk] = updateQN(pk, UPDATEQ);
            
            % If no QRS has been detected within 1.5 R-to-R intervals, 
            % there was a peak that was larger than half the 
            % detection threshold, and the peak followed the preceding 
            % detection by at least 360ms, classify that peak as a QRS 
            % complex
            
            % persistent sbpeak = 0; sbcount = MS1650
            if (count >= MS360) && (pk > sbpeak)
                sbpeak = pk;
                sbloc = count;
                threshold(:) = bitsra(threshold,1);
                
                if (count > sbcount) && (sbpeak > threshold)
                    sbcount = updateRR(sbloc);
                    lastQRSDelay(:) = count;
                    % threshold = threshold >> 1;
                    count(:) = 0;
                    sbpeak(:) = 0;
                end
            end
            
        end
    end
    QRSDelay = lastQRSDelay;
    thisThreshold = threshold;
    mminpk=minpk;
end

%**************************************************************************
%  UpdateQN takes a new QRS or noise peak value and updates the
%  QRS or noise mean estimate and detection threshold.
%  Input :
%  x - new QRS peak or noise peak value
%  Qflag - true (update QRS mean estimate), 
%          false (update Noise mean estimate)
% **************************************************************************/
function [det_thresh,det_minpeak] = updateQN(x, Qflag)
  persistent QSum
  persistent NSum
  persistent Qz Nz nQ nN

  if isempty(NSum)
      nQ = uint8(0);
      nN = uint8(0);
      Qz = zeros(8,1,'like',x);
      Nz = zeros(8,1,'like',x);
      QSum = cast(0, 'like', x);
      NSum = cast(0, 'like', x);
  end

  det_thresh = cast(0, 'like', x);
  if Qflag %&& x ~= cast(0,'like',x)
      Qz(nQ+1) = x;
      nQ = bitand(nQ+1,uint8(7));
      QSum(:) = sum(Qz);
  else
      Nz(nN+1) = x;
      nN = bitand(nN+1,uint8(7));
      NSum(:) = sum(Nz);
  end
  det_thresh(:) = QSum-NSum ;
  det_thresh(:) = NSum + bitsra(det_thresh,1) - bitsra(det_thresh,3);
  det_thresh(:) = bitsra(det_thresh, 3);

  det_minpeak(:)=bitsra((QSum-NSum), 4)+bitsra(NSum,3);
end

%**************************************************************************
%  UpdateRR takes a new RR value and updates the RR mean estimate
%*************************************************************************/
function sbcount = updateRR(x)
  persistent RRSum
  persistent zR 
  persistent nR

  if isempty(RRSum)
      nR = uint8(0);
      zR = cast(MS1000*ones(8,1, 'int16'),'like',x);
      RRSum = cast(bitsll(MS1000,3), 'like', x);
  end
  
  sbcount = cast(0, 'like', x);
  zR(nR+1) = x;
  nR = bitand(nR+1,uint8(7));
  RRSum(:) = sum(bitsra(zR,3));
  
  sbcount(:) = RRSum + bitsra(RRSum, 1); % = 1.5RRSum
  sbcount(:) = bitsra(sbcount, 3);
  sbcount(:) = sbcount + MS80; % WINDOW_WIDTH
end

function n = MS80
% The number of samples in 95 milli-seconds, where FS is the sample rate
    %FS = 250;
    FS=250;
    n = int16(80 * FS / 1000);
end

function n = MS95
% The number of samples in 95 milli-seconds, where FS is the sample rate
    %FS = 250;
    FS=250;
    n = int16(95 * FS / 1000);
end

function n = MS196
% The number of samples in 196 milli-seconds, where FS is the sample rate
    %FS = 250;
    FS=250;
    n = int16(196* FS / 1000);
end

function n = MS360
% The number of samples in 360 milli-seconds, where FS is the sample rate
    %FS = 250;
    FS=250;
    n = int16(360 * FS / 1000);
end

function n = MS1000
% The number of samples in 1000 milli-seconds, where FS is the sample rate
    %FS = 250;
    FS=250;
    n = int16(1000 * FS / 1000);
end

function n = MS1650
% The number of samples in 1650 milli-seconds, where FS is the sample rate
    %FS = 250;
    FS=250;
    n = int16(1650 * FS / 1000);
end
