function exceeded = hasExceededThreshold(signal, time, threshold, duration)
    % hasExceededThreshold determines if a signal has exceeded a given threshold
    % for a specific duration of time.
    %
    % Inputs:
    %   signal   - Array of signal values.
    %   time     - Array of time values corresponding to the signal. This can be
    %              in seconds or any consistent time unit. The length of time
    %              should match the length of the signal.
    %   threshold - The threshold value to check against the signal.
    %   duration - The duration of time the signal needs to exceed the threshold.
    %
    % Output:
    %   exceeded - Boolean value indicating if the signal has exceeded the
    %              threshold for the specified duration.

    % Ensure the input arrays are column vectors
    signal = signal(:);
    time = time(:);

    % Validate inputs
    if length(signal) ~= length(time)
        error('Signal and time arrays must have the same length.');
    end

    % Find indices where the signal exceeds the threshold
    exceedIndices = find(signal > threshold);

    % If no indices exceed the threshold, return false
    if isempty(exceedIndices)
        exceeded = false;
        return;
    end

    % Check duration of consecutive exceedances
    for i = 1:length(exceedIndices)
        startIdx = exceedIndices(i);
        
        % Find the end of the current exceedance streak
        endIdx = startIdx;
        while endIdx < length(signal) && signal(endIdx) > threshold
            endIdx = endIdx + 1;
        end

        % Calculate the time duration of the exceedance
        timeExceeded = time(endIdx) - time(startIdx);

        % Check if the duration exceeds the specified threshold
        if timeExceeded >= duration
            exceeded = true;
            return;
        end

        % Move to the next potential exceedance start
        i = find(exceedIndices > endIdx, 1, 'first') - 1;
        if isempty(i)
            break;
        end
    end

    % If no exceedance found for the required duration
    exceeded = false;
end