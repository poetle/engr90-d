%% note: commented code shows a longstanding hsitory
%% of the various approaches taken to qualitatively and quantiatively
%% explore tremors of various types. as such, numerous algorithms and
%% plots are attempted to perform this objective.

function plot_3d_time(port_in)
    % instructions:
        % 1. upload arduinoIDE script (rx channel unplugged) then close
        % 2. execute MATLAB script via command window(rx plugged)
    % port_in = "/dev/cu.usbmodem1101";

    % reset
    close all; clc;


    % setup
    baud_rate = 115200; % bits per second
    arduino = serialport(port_in, baud_rate);
    sample_rate = 200; % hertz
    time_lim = 30;
    ardui_num_cols = 6;
    datapoints = zeros(sample_rate*time_lim,ardui_num_cols);
    % xyz_points = zeros(sample_rate*time_lim,1);
    time = [];
    t = (0:sample_rate*time_lim)*(1/sample_rate);
    rate = 10;
    draw_rate = round(sample_rate/rate); % draw at rate per second
    skipline = 1;
    tic;
    idx = 1;
    figure;
    file_id = fopen("imu_data.txt", "w");

    while(toc < time_lim)
       
        if skipline == 0
            % header: yaw, pitch, roll, x, y, z
            labels = strsplit(readline(arduino)); % first line is header
            fprintf(file_id, "%s,%s,%s,%s,%s,%s\n", labels);
            skipline = 1;
        end

        datapoint = readline(arduino);
        new_data = str2double(strsplit(datapoint,","));
        datapoints(idx,:) = new_data;
        idx = idx + 1;
        total_points = length(datapoints(1:idx-1));
        fprintf(file_id, "%f,%f,%f,%f,%f,%f\n", new_data);

        now = (total_points - 1)/sample_rate;
        time = [time, now]; % check time to pre-allocate per run, save memory

        if mod(total_points, draw_rate) == 0
            % 2d plot
            % plot(time, datapoints);
            % title('serial log: ctrl + c to halt')
            % xlabel('time (s)')
            % ylabel('voltage (V)')
            % legend(labels(1),labels(2),labels(3), ...
            %        labels(4),labels(5),labels(6))
         
            x_coord = datapoints(1:idx-1, 4);
            y_coord = datapoints(1:idx-1, 5);
            z_coord = datapoints(1:idx-1, 6);

            % apply smoothening
            % window_size = 10; % adjust according to IMU sensitivity
            % x_coord2 = movmean(x_coord, window_size);
            % y_coord2 = movmean(y_coord, window_size);
            % z_coord2 = movmean(z_coord, window_size);
            % savitzky-golay idea

            % implement quadrature to get formula
            % or cumsum
            x_coord3 = cumsum(x_coord,"omitnan");
            y_coord3 = cumsum(y_coord,"omitnan");
            z_coord3 = cumsum(z_coord,"omitnan");

            % 3d plot
            % plot3(x_coord3, y_coord3, z_coord3);
            plot3(x_coord, y_coord, z_coord);

            %% newtonian mechanics
            % integrate -> velocity
            % dt = mean(diff(t)); % uniform sampling
            % v_x = cumsum(x_coord)*dt; v_y = cumsum(y_coord)*dt; v_z = cumsum(z_coord)*dt; % accel in m/s^2
            
            % integrate -> displacement
            % dst_x = cumsum(v_x)*dt; dst_y = cumsum(v_y)*dt; dst_z = cumsum(v_z)*dt;
            % figure(1); subplot(2,1,1);
            % plot3(v_x, v_y, v_z); hold on;
            % title('serial log: ctrl + c to halt');
             
            % axes equal
            xlabel("x'' (meters/second^2)")
            ylabel("y'' (meters/second^2)")
            zlabel("z'' (meters/second^2)")
            % legend("Original acceleration in real-time",...
            %        "smoothed acceleration in real-time")
            title("Raw acceleration versus time");
            grid on

            % xlim([min(v_x, [], "all") - 0.1, max(v_x, [], "all") + 0.1])
            % ylim([min(v_y, [], "all") - 0.1, max(v_y, [], "all") + 0.1])
            % zlim([min(v_z, [], "all") - 0.1, max(v_z, [], "all") + 0.1])

            xlim([min(x_coord, [], "all") - 0.1, max(x_coord, [], "all") + 0.1])
            ylim([min(y_coord, [], "all") - 0.1, max(y_coord, [], "all") + 0.1])
            zlim([min(z_coord, [], "all") - 0.1, max(z_coord, [], "all") + 0.1])

            % xlim([min(x_coord3, [], "all") - 0.1, max(x_coord3, [], "all") + 0.1])
            % ylim([min(y_coord3, [], "all") - 0.1, max(y_coord3, [], "all") + 0.1])
            % zlim([min(z_coord3, [], "all") - 0.1, max(z_coord3, [], "all") + 0.1])
             
            pause(0.01)

            drawnow
            
            % xyz_points(1:length(dst_x),:) = sqrt(dst_x.^2 + dst_y.^2 + dst_z.^2);
            % subplot(2,1,2);
            % plot(time,xyz_points(1:length(dst_x),:));
            % xlabel('x(t)')
            % ylabel('y(t)')
            % zlabel('z(t)')
            % legend("Original displacement in real-time",...
            %         "smoothed displacement in real-time")
            % ylim([min(xyz_points, [], "all") - 0.1, max(x_coord, [], "all") + 0.1])

        end
    end

    fclose(file_id);
end
