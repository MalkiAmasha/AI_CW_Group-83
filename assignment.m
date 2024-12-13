% Load datasets
clear; clc;

dataDir = 'D:\@NSBM\@NSBM (Nlearn)\3 rd year\1 sem\AI\CW-Data'; 

% Specify the number of users and features
num_users = 10; 
features = ["FreqD_FDay", "TimeD_FDay", "TimeD_FreqD_FDay", ...
            "FreqD_MDay", "TimeD_MDay", "TimeD_FreqD_MDay"]; 

% Initialize matrices to store data
time_domain_features = [];
freq_domain_features = [];
time_freq_combined_features = [];

% Iterate through all users and features
for user = 1:num_users
    for feature = 1:numel(features)
        % Construct file name dynamically
        filename = sprintf('U%02d_Acc_%s.mat', user, features(feature));
        
        % Check if the file exists
        if isfile(filename)
            % Load the dataset
            data = load(filename);
            
            % Extract the variable name dynamically
            field_names = fieldnames(data); % Get all variable names in the file
            features_data = data.(field_names{1}); % Access the first variable
            
            % Categorize data based on domain type
            if contains(features(feature), 'FreqD') && ~contains(features(feature), 'TimeD')
                freq_domain_features = [freq_domain_features; features_data];
            elseif contains(features(feature), 'TimeD_FreqD')
                time_freq_combined_features = [time_freq_combined_features; features_data];
            elseif contains(features(feature), 'TimeD')
                time_domain_features = [time_domain_features; features_data];
            end
        else
            fprintf('File %s not found.\n', filename);
        end
    end
end

% Calculate intra-user variance for each feature set
intra_user_variance_time = zeros(num_users, size(time_domain_features, 2));
intra_user_variance_freq = zeros(num_users, size(freq_domain_features, 2));
intra_user_variance_combined = zeros(num_users, size(time_freq_combined_features, 2));

for user = 1:num_users
    % Assume each user has 36 samples
    start_idx = (user - 1) * 36 + 1;
    end_idx = user * 36;
    
    % Extract features for each user
    user_time_features = time_domain_features(start_idx:end_idx, :);
    user_freq_features = freq_domain_features(start_idx:end_idx, :);
    user_combined_features = time_freq_combined_features(start_idx:end_idx, :);
    
    % Compute variance for each feature
    intra_user_variance_time(user, :) = var(user_time_features, 0, 1);
    intra_user_variance_freq(user, :) = var(user_freq_features, 0, 1);
    intra_user_variance_combined(user, :) = var(user_combined_features, 0, 1);
end

% Compute Inter-user variance
inter_user_variance_time = var(time_domain_features, 0, 1);
inter_user_variance_freq = var(freq_domain_features, 0, 1);
inter_user_variance_combined = var(time_freq_combined_features, 0, 1);

% Insights from Variance
fprintf('Insights from Variance Analysis:\n\n');
fprintf('Time Domain: Highest inter-user variance observed for Feature %d\n', find(inter_user_variance_time == max(inter_user_variance_time)));
fprintf('Frequency Domain: Highest inter-user variance observed for Feature %d\n', find(inter_user_variance_freq == max(inter_user_variance_freq)));
fprintf('Combined Features: Highest inter-user variance observed for Feature %d\n\n', find(inter_user_variance_combined == max(inter_user_variance_combined)));

% Print User-Wise Intra-User Variance by Domain 
fprintf('--- User-Wise Intra-User Variance ---\n\n');
for user = 1:num_users
    fprintf('User %d - Time Domain Variance: %.4f (Average)\n', user, mean(intra_user_variance_time(user, :)));
    fprintf('User %d - Frequency Domain Variance: %.4f (Average)\n', user, mean(intra_user_variance_freq(user, :)));
    fprintf('User %d - Combined Domain Variance: %.4f (Average)\n\n', user, mean(intra_user_variance_combined(user, :)));
end

% Inter-user variance summary
fprintf('\n--- Inter-User Variance Analysis (Average Values)---\n\n');
fprintf('Time Domain - Average Inter-User Variance: %.4f\n', mean(inter_user_variance_time));
fprintf('Frequency Domain - Average Inter-User Variance: %.4f\n', mean(inter_user_variance_freq));
fprintf('Combined Domain - Average Inter-User Variance: %.4f\n\n', mean(inter_user_variance_combined));

% Calculate descriptive statistics for intra-user variances
descriptive_statistics_time = struct( ...
    'mean', mean(intra_user_variance_time), ...
    'median', median(intra_user_variance_time), ...
    'std', std(intra_user_variance_time), ...
    'max', max(intra_user_variance_time), ...
    'min', min(intra_user_variance_time), ...
    'range', range(intra_user_variance_time));

descriptive_statistics_freq = struct( ...
    'mean', mean(intra_user_variance_freq), ...
    'median', median(intra_user_variance_freq), ...
    'std', std(intra_user_variance_freq), ...
    'max', max(intra_user_variance_freq), ...
    'min', min(intra_user_variance_freq), ...
    'range', range(intra_user_variance_freq));

descriptive_statistics_combined = struct( ...
    'mean', mean(intra_user_variance_combined), ...
    'median', median(intra_user_variance_combined), ...
    'std', std(intra_user_variance_combined), ...
    'max', max(intra_user_variance_combined), ...
    'min', min(intra_user_variance_combined), ...
    'range', range(intra_user_variance_combined));

fprintf('--- Descriptive Statistics for Intra-User ---\n\n');

% Display descriptive statistics
disp('Descriptive Statistics for Time Domain Features (Intra-User)');
disp(descriptive_statistics_time);

disp('Descriptive Statistics for Frequency Domain Features (Intra-User)');
disp(descriptive_statistics_freq);

disp('Descriptive Statistics for Combined Features (Intra-User)');
disp(descriptive_statistics_combined);

% Extract statistics into arrays for plotting
time_stats = [descriptive_statistics_time.mean; ...
              descriptive_statistics_time.median; ...
              descriptive_statistics_time.std; ...
              descriptive_statistics_time.max; ...
              descriptive_statistics_time.min; ...
              descriptive_statistics_time.range];

freq_stats = [descriptive_statistics_freq.mean; ...
              descriptive_statistics_freq.median; ...
              descriptive_statistics_freq.std; ...
              descriptive_statistics_freq.max; ...
              descriptive_statistics_freq.min; ...
              descriptive_statistics_freq.range];

combined_stats = [descriptive_statistics_combined.mean; ...
                  descriptive_statistics_combined.median; ...
                  descriptive_statistics_combined.std; ...
                  descriptive_statistics_combined.max; ...
                  descriptive_statistics_combined.min; ...
                  descriptive_statistics_combined.range];

% Define labels for the statistics
stat_labels = {'Mean', 'Median', 'Std Dev', 'Max', 'Min', 'Range'};

% Visualization for Time Domain Features
figure;
bar(time_stats', 'grouped');
title('Descriptive Statistics for Time Domain Features');
xlabel('Features');
ylabel('Value');
legend(stat_labels, 'Location', 'Best');
grid on;

% Visualization for Frequency Domain Features
figure;
bar(freq_stats', 'grouped');
title('Descriptive Statistics for Frequency Domain Features');
xlabel('Features');
ylabel('Value');
legend(stat_labels, 'Location', 'Best');
grid on;

% Visualization for Combined Features
figure;
bar(combined_stats', 'grouped');
title('Descriptive Statistics for Combined Features');
xlabel('Features');
ylabel('Value');
legend(stat_labels, 'Location', 'Best');
grid on;

% Visualization for Descriptive Statistics of Intra-User Variance
figure;

% Mean Variance Visualization
subplot(3, 2, 1);
hold on;
plot(descriptive_statistics_time.mean, '-o', 'LineWidth', 1.5);
plot(descriptive_statistics_freq.mean, '-s', 'LineWidth', 1.5);
plot(descriptive_statistics_combined.mean, '-d', 'LineWidth', 1.5);
title('Mean Variance Across Features');
xlabel('Feature Index');
ylabel('Mean Variance');
legend('Time Domain', 'Frequency Domain', 'Combined Domain');
hold off;

% Median Variance Visualization
subplot(3, 2, 2);
hold on;
plot(descriptive_statistics_time.median, '-o', 'LineWidth', 1.5);
plot(descriptive_statistics_freq.median, '-s', 'LineWidth', 1.5);
plot(descriptive_statistics_combined.median, '-d', 'LineWidth', 1.5);
title('Median Variance Across Features');
xlabel('Feature Index');
ylabel('Median Variance');
legend('Time Domain', 'Frequency Domain', 'Combined Domain');
hold off;

% Standard Deviation Variance Visualization
subplot(3, 2, 3);
hold on;
plot(descriptive_statistics_time.std, '-o', 'LineWidth', 1.5);
plot(descriptive_statistics_freq.std, '-s', 'LineWidth', 1.5);
plot(descriptive_statistics_combined.std, '-d', 'LineWidth', 1.5);
title('Standard Deviation Variance Across Features');
xlabel('Feature Index');
ylabel('Std Variance');
legend('Time Domain', 'Frequency Domain', 'Combined Domain');
hold off;

% Maximum Variance Visualization
subplot(3, 2, 4);
hold on;
plot(descriptive_statistics_time.max, '-o', 'LineWidth', 1.5);
plot(descriptive_statistics_freq.max, '-s', 'LineWidth', 1.5);
plot(descriptive_statistics_combined.max, '-d', 'LineWidth', 1.5);
title('Maximum Variance Across Features');
xlabel('Feature Index');
ylabel('Max Variance');
legend('Time Domain', 'Frequency Domain', 'Combined Domain');
hold off;

% Minimum Variance Visualization
subplot(3, 2, 5);
hold on;
plot(descriptive_statistics_time.min, '-o', 'LineWidth', 1.5);
plot(descriptive_statistics_freq.min, '-s', 'LineWidth', 1.5);
plot(descriptive_statistics_combined.min, '-d', 'LineWidth', 1.5);
title('Minimum Variance Across Features');
xlabel('Feature Index');
ylabel('Min Variance');
legend('Time Domain', 'Frequency Domain', 'Combined Domain');
hold off;

% Range Variance Visualization
subplot(3, 2, 6);
hold on;
plot(descriptive_statistics_time.range, '-o', 'LineWidth', 1.5);
plot(descriptive_statistics_freq.range, '-s', 'LineWidth', 1.5);
plot(descriptive_statistics_combined.range, '-d', 'LineWidth', 1.5);
title('Range Variance Across Features');
xlabel('Feature Index');
ylabel('Range Variance');
legend('Time Domain', 'Frequency Domain', 'Combined Domain');
hold off;

num_features = 131; % Number of features 

% Initialize a cell array to store feature-wise inter-variance for all user pairs
inter_variance = cell(num_users, num_users);

% Loop over all user pairs
for user1 = 1:num_users
    for user2 = (user1+1):num_users
        % Extract samples for both users
        start_idx_user1 = (user1-1)*36 + 1;
        end_idx_user1 = user1*36;
        start_idx_user2 = (user2-1)*36 + 1;
        end_idx_user2 = user2*36;
        
        % Compute feature-wise inter-variance
        inter_variance_user_pair = var(time_freq_combined_features(start_idx_user1:end_idx_user1, :) - ...
                                       time_freq_combined_features(start_idx_user2:end_idx_user2, :), 0, 1);
        % Store the result
        inter_variance{user1, user2} = inter_variance_user_pair;
    end
end

% Visualization: Split the 10 user-wise plots into 3 windows
num_windows = 3; % Number of separate figure windows
users_per_window = ceil(num_users / num_windows); % Divide users across windows

for window = 1:num_windows
    figure;
    start_user = (window - 1) * users_per_window + 1;
    end_user = min(window * users_per_window, num_users);
    
    for user = start_user:end_user
        subplot(users_per_window, 1, user - start_user + 1); % Adjust subplot layout
        hold on;
        for other_user = 1:num_users
            if user ~= other_user && ~isempty(inter_variance{min(user, other_user), max(user, other_user)})
                % Extract inter-variance data
                inter_variance_data = inter_variance{min(user, other_user), max(user, other_user)};
                % Plot inter-variance for this user pair
                plot(1:num_features, inter_variance_data, '-o', 'DisplayName', sprintf('User %02d vs User %02d', user, other_user));
            end
        end
        hold off;
        
        % Configure plot titles and labels
        title(sprintf('Inter-Variance: User %02d', user));
        xlabel('Feature Index');
        ylabel('Inter-Variance');
        legend('show', 'Location', 'bestoutside'); % Adjust legend placement
        grid on;
    end
    
    % Adjust figure layout
    sgtitle(sprintf('Inter-Variance Plots for Users %02d to %02d', start_user, end_user)); % Title for each figure
end

num_time_features = size(time_domain_features, 2); % Number of time-domain features
num_freq_features = size(freq_domain_features, 2); % Number of frequency-domain features

% Initialize cell arrays to store domain-wise inter-variance for all user pairs
inter_variance_time = cell(num_users, num_users);
inter_variance_freq = cell(num_users, num_users);

% Loop over all user pairs
for user1 = 1:num_users
    for user2 = (user1+1):num_users
        % Extract samples for both users
        start_idx_user1 = (user1-1)*36 + 1;
        end_idx_user1 = user1*36;
        start_idx_user2 = (user2-1)*36 + 1;
        end_idx_user2 = user2*36;
        
        % Compute time-domain inter-variance
        time_diff = time_domain_features(start_idx_user1:end_idx_user1, :) - ...
                    time_domain_features(start_idx_user2:end_idx_user2, :);
        inter_variance_time_user_pair = var(time_diff, 0, 1);
        
        % Compute frequency-domain inter-variance
        freq_diff = freq_domain_features(start_idx_user1:end_idx_user1, :) - ...
                    freq_domain_features(start_idx_user2:end_idx_user2, :);
        inter_variance_freq_user_pair = var(freq_diff, 0, 1);
        
        % Store the results
        inter_variance_time{user1, user2} = inter_variance_time_user_pair;
        inter_variance_freq{user1, user2} = inter_variance_freq_user_pair;
    end
end

% Visualization: Domain-Wise Inter-Variance
% Time-Domain Visualization
figure;
sgtitle('Domain-Wise Inter-Variance: Time Domain');
for user = 1:num_users
    subplot(ceil(num_users/2), 2, user); % Split into multiple subplots
    hold on;
    for other_user = 1:num_users
        if user ~= other_user && ~isempty(inter_variance_time{min(user, other_user), max(user, other_user)})
            % Extract time-domain inter-variance data
            inter_variance_data_time = inter_variance_time{min(user, other_user), max(user, other_user)};
            % Plot inter-variance for this user pair
            plot(1:num_time_features, inter_variance_data_time, '-o', ...
                 'DisplayName', sprintf('User %02d vs User %02d', user, other_user));
        end
    end
    hold off;
    title(sprintf('Time Domain: User %02d', user));
    xlabel('Feature Index');
    ylabel('Inter-Variance');
    legend('show', 'Location', 'bestoutside');
    grid on;
end

% Frequency-Domain Visualization
figure;
sgtitle('Domain-Wise Inter-Variance: Frequency Domain');
for user = 1:num_users
    subplot(ceil(num_users/2), 2, user); % Split into multiple subplots
    hold on;
    for other_user = 1:num_users
        if user ~= other_user && ~isempty(inter_variance_freq{min(user, other_user), max(user, other_user)})
            % Extract frequency-domain inter-variance data
            inter_variance_data_freq = inter_variance_freq{min(user, other_user), max(user, other_user)};
            % Plot inter-variance for this user pair
            plot(1:num_freq_features, inter_variance_data_freq, '-o', ...
                 'DisplayName', sprintf('User %02d vs User %02d', user, other_user));
        end
    end
    hold off;
    title(sprintf('Frequency Domain: User %02d', user));
    xlabel('Feature Index');
    ylabel('Inter-Variance');
    legend('show', 'Location', 'bestoutside');
    grid on;
end

% Dynamically determine the number of features in each dataset
num_time_features = size(time_domain_features, 2); % Features in time domain
num_freq_features = size(freq_domain_features, 2); % Features in frequency domain
num_combined_features = size(time_freq_combined_features, 2); % Features in combined domain

% Initialize matrices to store intra-user variance for each user
intra_user_variance_time = zeros(num_users, num_time_features);
intra_user_variance_freq = zeros(num_users, num_freq_features);
intra_user_variance_combined = zeros(num_users, num_combined_features);

% Loop over each user and calculate variance for each feature set
for user = 1:num_users
    % Extract samples for each user (assuming 36 samples per feature)
    start_idx = (user-1)*36 + 1;
    end_idx = user*36;
    
    % Calculate intra-user variance for Time Domain Features
    for feature = 1:num_time_features
        user_time_feature = time_domain_features(start_idx:end_idx, feature);
        intra_user_variance_time(user, feature) = var(user_time_feature); % Variance for each feature
    end
    
    % Calculate intra-user variance for Frequency Domain Features
    for feature = 1:num_freq_features
        user_freq_feature = freq_domain_features(start_idx:end_idx, feature);
        intra_user_variance_freq(user, feature) = var(user_freq_feature); % Variance for each feature
    end
    
    % Calculate intra-user variance for Combined Domain Features
    for feature = 1:num_combined_features
        user_combined_feature = time_freq_combined_features(start_idx:end_idx, feature);
        intra_user_variance_combined(user, feature) = var(user_combined_feature); % Variance for each feature
    end
end

% Visualization of User-Wise Intra-Variance
% Create figures for the variance visualizations
% Plot Intra-User Variance for Time Domain Features
figure;
subplot(3, 1, 1);
hold on;
for user = 1:num_users
    plot(1:num_time_features, intra_user_variance_time(user, :), '-o', 'DisplayName', sprintf('User %d', user));
end
title('User-Wise Intra-Variance - Time Domain Features');
xlabel('Feature Index (1 to ' + string(num_time_features) + ')'); % Dynamic X-axis label
ylabel('Intra-Variance');
legend('show');
grid on;

% Plot Intra-User Variance for Frequency Domain Features
subplot(3, 1, 2);
hold on;
for user = 1:num_users
    plot(1:num_freq_features, intra_user_variance_freq(user, :), '-o', 'DisplayName', sprintf('User %d', user));
end
title('User-Wise Intra-Variance - Frequency Domain Features');
xlabel('Feature Index (1 to ' + string(num_freq_features) + ')'); % Dynamic X-axis label
ylabel('Intra-Variance');
legend('show');
grid on;

% Plot Intra-User Variance for Combined Domain Features
subplot(3, 1, 3);
hold on;
for user = 1:num_users
    plot(1:num_combined_features, intra_user_variance_combined(user, :), '-o', 'DisplayName', sprintf('User %d', user));
end
title('User-Wise Intra-Variance - Combined Domain Features');
xlabel('Feature Index (1 to ' + string(num_combined_features) + ')'); % Dynamic X-axis label
ylabel('Intra-Variance');
legend('show');
grid on;

% Sample Similarity Analysis
% Using Pearson Correlation and Euclidean Distance
correlation_time = corr(time_domain_features');
correlation_freq = corr(freq_domain_features');
correlation_combined = corr(time_freq_combined_features');

% Calculate Euclidean distance for user samples (normalized)
euclidean_dist_time = pdist(time_domain_features, 'euclidean');
euclidean_dist_freq = pdist(freq_domain_features, 'euclidean');
euclidean_dist_combined = pdist(time_freq_combined_features, 'euclidean');

% Plot heatmaps for Pearson Correlation (Sample Similarities)
figure;
subplot(1, 3, 1);
imagesc(correlation_time);
colorbar;
title('Correlation Matrix - Time Domain Features');
xlabel('Users');
ylabel('Users');

subplot(1, 3, 2);
imagesc(correlation_freq);
colorbar;
title('Correlation Matrix - Frequency Domain Features');
xlabel('Users');
ylabel('Users');

subplot(1, 3, 3);
imagesc(correlation_combined);
colorbar;
title('Correlation Matrix - Combined Features');
xlabel('Users');
ylabel('Users');

% Visualizing Euclidean Distance (User Sample Similarities)
figure;
subplot(1, 3, 1);
dendrogram(linkage(euclidean_dist_time), 'ColorThreshold', 0.5);
title('Euclidean Distance - Time Domain Features');

subplot(1, 3, 2);
dendrogram(linkage(euclidean_dist_freq), 'ColorThreshold', 0.5);
title('Euclidean Distance - Frequency Domain Features');

subplot(1, 3, 3);
dendrogram(linkage(euclidean_dist_combined), 'ColorThreshold', 0.5);
title('Euclidean Distance - Combined Features');

% Descriptive Statistics Calculation
function stats = calculate_descriptive_statistics(data)
    stats.mean = mean(data);
    stats.median = median(data);
    stats.mode = mode(data);
    stats.range = range(data);
    stats.std_dev = std(data);
    
end

% Analyze descriptive statistics for each feature set
time_stats = calculate_descriptive_statistics(time_domain_features);
freq_stats = calculate_descriptive_statistics(freq_domain_features);
combined_stats = calculate_descriptive_statistics(time_freq_combined_features);

% Display the results
disp('Descriptive Statistics for Time Domain Features (inter-user)');
disp(time_stats);

disp('Descriptive Statistics for Frequency Domain Features (inter-user)');
disp(freq_stats);

disp('Descriptive Statistics for Combined Features (inter-user)');
disp(combined_stats);

% Visualization: Histogram and Boxplots
figure;

% Time Domain Features
subplot(3, 2, 1);
histogram(time_domain_features);
title('Histogram - Time Domain Features');
xlabel('Value');
ylabel('Frequency');

subplot(3, 2, 2);
boxplot(time_domain_features);
title('Boxplot - Time Domain Features');
xlabel('Features');
ylabel('Values');

% Frequency Domain Features
subplot(3, 2, 3);
histogram(freq_domain_features);
title('Histogram - Frequency Domain Features');
xlabel('Value');
ylabel('Frequency');

subplot(3, 2, 4);
boxplot(freq_domain_features);
title('Boxplot - Frequency Domain Features');
xlabel('Features');
ylabel('Values');

% Combined Features
subplot(3, 2, 5);
histogram(time_freq_combined_features);
title('Histogram - Combined Features');
xlabel('Value');
ylabel('Frequency');

subplot(3, 2, 6);
boxplot(time_freq_combined_features);
title('Boxplot - Combined Features');
xlabel('Features');
ylabel('Values');

%% Task 2: Feedforward Neural Network for Multi-Class Classification

% Set a random seed for reproducibility
rng(42);  

% Initialize matrices for features and labels
all_features = [];
all_labels = [];

% Load datasets for all users
for user = 1:num_users
    user_features = [];
    for feature = 1:numel(features)
        % Build file path
        filename = sprintf('U%02d_Acc_%s.mat', user, features(feature));
        filepath = fullfile(dataDir, filename);

        if isfile(filepath)
            data = load(filepath);
            field_names = fieldnames(data);
            feature_data = data.(field_names{1});
            user_features = [user_features, feature_data];
        else
            fprintf('File %s not found.\n', filename);
        end
    end

    % Append user's features and corresponding labels
    all_features = [all_features; user_features];
    all_labels = [all_labels; repmat(user, size(user_features, 1), 1)];
end

% Normalize features (z-score standardization)
all_features = zscore(all_features);

% Apply PCA for dimensionality reduction (retain 90% variance)
[coeff, score, ~, ~, explained_variance] = pca(all_features);
num_components = find(cumsum(explained_variance) >= 90, 1); % Retain 90% variance
all_features = score(:, 1:num_components);

% Convert labels to categorical
all_labels = categorical(all_labels);

% Split data into training (70%) and testing (30%)
train_ratio = 0.7;
num_samples = size(all_features, 1);
train_size = round(train_ratio * num_samples);

% Stratified sampling
[unique_labels, ~, label_indices] = unique(all_labels);
stratified_indices = [];

for i = 1:length(unique_labels)
    class_indices = find(label_indices == i);
    class_train_size = round(length(class_indices) * train_ratio);
    rng(42 + i); % Fixed seed for reproducibility
    class_train_indices = datasample(class_indices, class_train_size, 'Replace', false);
    class_test_indices = setdiff(class_indices, class_train_indices);
    stratified_indices = [stratified_indices; class_train_indices; class_test_indices];
end

% Shuffle indices
rand_indices = randperm(length(stratified_indices));
stratified_indices = stratified_indices(rand_indices);

% Split indices
train_indices = stratified_indices(1:train_size);
test_indices = stratified_indices(train_size + 1:end);

X_train = all_features(train_indices, :)';
Y_train = dummyvar(all_labels(train_indices))';
X_test = all_features(test_indices, :)';
Y_test = dummyvar(all_labels(test_indices))';

% Configure Feedforward Neural Network
hidden_layer_sizes = [64, 32]; % Reduced layer sizes
net = feedforwardnet(hidden_layer_sizes, 'trainscg'); % Scaled conjugate gradient

% Set activation functions
net.layers{1}.transferFcn = 'poslin'; % ReLU
net.layers{2}.transferFcn = 'tansig'; % Hyperbolic tangent
net.layers{3}.transferFcn = 'softmax'; % Output layer activation

% Configure training parameters
net.trainParam.epochs = 1000; % Reduced epochs
net.trainParam.goal = 1e-3; % Less stringent error goal
net.divideParam.trainRatio = 0.7;
net.divideParam.valRatio = 0.15;
net.divideParam.testRatio = 0.15;
net.performFcn = 'crossentropy'; % Cross-entropy loss function

% Train the Neural Network
[net, tr] = train(net, X_train, Y_train);

% Evaluate Model Performance
Y_train_pred = net(X_train);
[~, train_predicted_labels] = max(Y_train_pred, [], 1);
[~, train_true_labels] = max(Y_train, [], 1);
train_accuracy = sum(train_predicted_labels == train_true_labels) / length(train_true_labels) * 100;

Y_test_pred = net(X_test);
[~, test_predicted_labels] = max(Y_test_pred, [], 1);
[~, test_true_labels] = max(Y_test, [], 1);
test_accuracy = sum(test_predicted_labels == test_true_labels) / length(test_true_labels) * 100;

% Compute Precision, Recall, and F1-score
confusion_test = confusionmat(test_true_labels, test_predicted_labels);
precision_test = diag(confusion_test) ./ sum(confusion_test, 2);
recall_test = diag(confusion_test) ./ sum(confusion_test, 1)';
f1_test = 2 * (precision_test .* recall_test) ./ (precision_test + recall_test);

% Handle NaN values
precision_test(isnan(precision_test)) = 0;
recall_test(isnan(recall_test)) = 0;
f1_test(isnan(f1_test)) = 0;

fprintf('--- Model Performance ---\n\n');
fprintf('Training Accuracy: %.2f%%\n', train_accuracy);
fprintf('Testing Accuracy: %.2f%%\n\n', test_accuracy);
fprintf('Average Precision (Test): %.2f%%\n', mean(precision_test) * 100);
fprintf('Average Recall (Test): %.2f%%\n', mean(recall_test) * 100);
fprintf('Average F1-score (Test): %.2f\n', mean(f1_test) * 100);

% Insights from the Initial Model
fprintf('\nInsights from the Initial FNN Model:\n\n');
fprintf('Number of features used: %d\n', size(all_features, 2));
fprintf('Training Accuracy indicates model fitting to training data.\n');
fprintf('Testing Accuracy reflects the model generalization to unseen data.\n');
fprintf('Optimization in Task 3 can focus on feature selection, layer configurations, or training parameters.\n\n');

% Visualizations
figure;
plotperform(tr); % Performance plot
figure;
plotconfusion(Y_test, Y_test_pred, 'Testing Data'); % Confusion matrix
figure;
plotroc(Y_test, Y_test_pred); % ROC curve

%% Task 3 Code - Optimizing with Different Classifiers and Feature Selection

rng(42);  

% --- Step 1: Variance-Based Feature Selection ---
variance_threshold = 0.01; % Threshold for low-variance features
feature_variances = var(all_features);
high_variance_indices = feature_variances > variance_threshold;
selected_features = all_features(:, high_variance_indices);

% --- Step 2: Principal Component Analysis (PCA) ---
explained_variance_threshold = 95; % Retain 95% variance
[coeff, score, latent] = pca(selected_features);
cumulative_variance = cumsum(latent) / sum(latent) * 100;
num_components = find(cumulative_variance >= explained_variance_threshold, 1);
reduced_features = score(:, 1:num_components);

% Normalize features
normalized_features = normalize(reduced_features);

% Convert labels to categorical
all_labels = categorical(all_labels);

% Split data into training (70%) and testing (30%)
train_ratio = 0.7;
num_samples = size(normalized_features, 1);
train_size = round(train_ratio * num_samples);
rand_indices = randperm(num_samples); % Shuffle the data
train_indices = rand_indices(1:train_size);
test_indices = rand_indices(train_size+1:end);

X_train = normalized_features(train_indices, :);
Y_train = all_labels(train_indices);
X_test = normalized_features(test_indices, :);
Y_test = all_labels(test_indices);

% --- Step 3: Compare Classifiers ---
results = table('Size', [0, 2], 'VariableTypes', {'string', 'double'}, ...
                'VariableNames', {'Classifier', 'Accuracy'});

% 1. Random Forest Classifier
rf_model = fitcensemble(X_train, Y_train, 'Method', 'Bag', 'NumLearningCycles', 50);
Y_pred_rf = predict(rf_model, X_test);
accuracy_rf = sum(Y_pred_rf == Y_test) / numel(Y_test) * 100;
results = [results; {"Random Forest", accuracy_rf}];

% 2. Support Vector Machine (SVM)
svm_model = fitcecoc(X_train, Y_train, 'Coding', 'onevsall');
Y_pred_svm = predict(svm_model, X_test);
accuracy_svm = sum(Y_pred_svm == Y_test) / numel(Y_test) * 100;
results = [results; {"SVM", accuracy_svm}];

% 3. K-Nearest Neighbors (KNN)
knn_model = fitcknn(X_train, Y_train, 'NumNeighbors', 5);
Y_pred_knn = predict(knn_model, X_test);
accuracy_knn = sum(Y_pred_knn == Y_test) / numel(Y_test) * 100;
results = [results; {"KNN", accuracy_knn}];

% 4. Naive Bayes
nb_model = fitcnb(X_train, Y_train);
Y_pred_nb = predict(nb_model, X_test);
accuracy_nb = sum(Y_pred_nb == Y_test) / numel(Y_test) * 100;
results = [results; {"Naive Bayes", accuracy_nb}];

% 5. Logistic Regression
logreg_model = fitcecoc(X_train, Y_train);  % Use fitcecoc instead of fitclinear
Y_pred_logreg = predict(logreg_model, X_test);
accuracy_logreg = sum(Y_pred_logreg == Y_test) / numel(Y_test) * 100;
results = [results; {"Logistic Regression", accuracy_logreg}];


% 6. Decision Tree Classifier
dt_model = fitctree(X_train, Y_train);
Y_pred_dt = predict(dt_model, X_test);
accuracy_dt = sum(Y_pred_dt == Y_test) / numel(Y_test) * 100;
results = [results; {"Decision Tree", accuracy_dt}];

% --- Step 4: Display Results ---
disp('--- Classifier Performance ---');
disp(results);

% --- Visualizations ---
figure;
bar(categorical(results.Classifier), results.Accuracy);
title('Classifier Accuracy Comparison');
ylabel('Accuracy (%)');
xlabel('Classifier');
grid on;

% --- Step 5: Insights ---
% Get the best-performing classifier and its accuracy
[best_accuracy, best_idx] = max(results.Accuracy);
best_classifier = results.Classifier{best_idx};  % Use curly braces to extract the string from the cell array

% Find the maximum accuracy
max_accuracy = max(results.Accuracy);

% Find all classifiers with the maximum accuracy
best_classifiers = results.Classifier(results.Accuracy == max_accuracy);

% Display all best-performing classifiers
fprintf('The best-performing classifiers are:\n');
for i = 1:length(best_classifiers)
    fprintf('%s with an accuracy of %.2f%%\n', best_classifiers{i}, max_accuracy);
end


% --- Compare Precision, Recall, and F1 Score for Random Forest and Naive Bayes ---
% Random Forest Performance
conf_matrix_rf = confusionmat(Y_test, Y_pred_rf);
precision_rf = diag(conf_matrix_rf) ./ sum(conf_matrix_rf, 2);
recall_rf = diag(conf_matrix_rf) ./ sum(conf_matrix_rf, 1)';
f1_score_rf = 2 * (precision_rf .* recall_rf) ./ (precision_rf + recall_rf);

% Naive Bayes Performance
conf_matrix_nb = confusionmat(Y_test, Y_pred_nb);
precision_nb = diag(conf_matrix_nb) ./ sum(conf_matrix_nb, 2);
recall_nb = diag(conf_matrix_nb) ./ sum(conf_matrix_nb, 1)';
f1_score_nb = 2 * (precision_nb .* recall_nb) ./ (precision_nb + recall_nb);

fprintf('\nRandom Forest F1-Score: %.2f%%\n', mean(f1_score_rf) * 100);
fprintf('Naive Bayes F1-Score: %.2f%%\n', mean(f1_score_nb) * 100);

% Visualize the decision tree 
% Train a Decision Tree classifier
tree_model = fitctree(X_train, Y_train);

% View the decision tree structure in graph mode
view(tree_model, 'Mode', 'graph');  
