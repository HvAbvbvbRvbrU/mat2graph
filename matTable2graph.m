%% ワークスペースの初期化
clear

%% ファイル & シート & セル範囲指定（読み込みファイルは閉じておくこと）
%------------------------------------------------------%
%   読み込みたいファイルのフォルダを指定                  %
%------------------------------------------------------%

%----------------- 初期値設定 (フォルダ設定) ------------%
%*** GUIで開いた時に最初に表示されるフォルダ ***%
initialDir = ['\\10.6.2.52\セラ技部34技室\資料：製品・ﾒｰｶ対応\500_制御\' ...
                '●テクノ制御Gr共有\01_メーカ別\04_RSA\HR16\07_品質確認シート\' ...
                'Dataset from RSA KOREA_2022-06-09\' ...
                '■データ\04_matデータ\作業場'];
%------------------------------------------------------%

%-------------- キャンセル時のエラー処理 --------------%
try 
    dirName = uigetdir(initialDir);                     % GUIでフォルダ取得
    dirName = append(dirName, '\');                     % フォルダ名の最後に\を追加
    files = dir([dirName, '*.mat']);                    % 拡張子指定
catch
    disp(' ')
    disp(' Folder select is canceled ')
    disp(' ')
    return                                              % プログラムの実行を終了
end
fileNum = length(files);                                % ファイル数取得

%% グラフ化
% 1.  Zac           Duty
% 2.  
% 3.  Engin RPM     Vehicle speed
% 4.  λ             Coolant temp.

xStart = 0;     % 時間軸 start
xEnd = 500;     % 時間軸 End   

for i = 1:fileNum
    %---------- matファイル 読み込み ----------%    
    disp('File loading...')
    load(fullfile(files(i).folder, files(i).name))
    [~,figName,~] = fileparts(files(i).name);

    tableRow = height(saveTable);                                   % saveTableの行数
    for n = 1:tableRow                                              % saveTableの行数だけループ
        if tableRow > 1                                             % 行数が2行以上なら
            windowName = strcat(figName,'_',num2str(n));     % Figureウインドウの表示名語尾に "_" と行数を追加
            figure('Name', windowName);                             
        else
            figure('Name', figName);                                 
        end

        %---------------<<< グラフ設定 >>>---------------%
        tiledlayout(5,1)
        %--------------- 1 個目 ---------------%
        ax1 = nexttile;
        
        %+++++ 1軸 +++++% Zac
        yyaxis left
        plot(saveTable{n,11}.time11, saveTable{n,11}.vSF5ZAC_bios__0__ETKC_2)
        ylabel('Zac [Ω]')
        ylim([0 100])
        yticks(0:20:100)
        
        %+++++ 2軸 +++++% Duty
        yyaxis right
        plot(saveTable{n,11}.time11, saveTable{n,11}.vAFSHDTY__0__ETKC_2*100)
        ylabel('Duty [%]')
        ylim([0 100])
        yticks(0:20:100)
        
        %+++++ 共通設定 +++++%
        xlim([xStart xEnd])
        xlabel('time [s]')
        grid on
        ax1.GridLineStyle = '--';
        
        %--------------- 2 個目 ---------------%
        ax2 = nexttile;
        
        %+++++ 1軸 +++++%    A/F値 Bosch, DN
%         yyaxis left
        hold on
            plot(saveTable{n,6}.time6, saveTable{n,6}.ES630_LA1_A_F_ES630_Lambda_1) % Bosch
            plot(saveTable{n,11}.time11, saveTable{n,11}.vARABF__0__ETKC_2)         % DN
            ylabel('A/F [-]')       
        hold off

        %+++++ 2軸 +++++%  なし
%         yyaxis right
        
        %+++++ 共通設定 +++++%
        xlim([xStart xEnd])
        xlabel('time [s]')
        grid on
        ax2.GridLineStyle = '--';
        box on
        legend('BOSCH', 'Plus6fz')

        %--------------- 3 個目 ---------------%
        ax3 = nexttile;
        
        %+++++ 1軸 +++++%    センサ電流
%         yyaxis left
        hold on
            plot(saveTable{n,6}.time6, saveTable{n,6}.ES630_LA1_Ipump_ES630_Lambda_1)   % Bosch
            plot(saveTable{n,11}.time11, saveTable{n,11}.vSF5IVAL_bios__0__ETKC_2*1000)      % DN            
            ylabel('Sensor current [mA]')
        hold off
        
        %+++++ 2軸 +++++%  なし
%         yyaxis right
        
        %+++++ 共通設定 +++++%
        xlim([xStart xEnd])
        xlabel('time [s]')
        grid on
        ax3.GridLineStyle = '--';
        box on
        legend('BOSCH', 'Plus6fz')
        %--------------- 4 個目 ---------------%
        ax4 = nexttile;
        
        %+++++ 1軸 +++++% Engine RPM
        yyaxis left
        plot(saveTable{n,10}.time10, saveTable{n,10}.vKNRPM_ETKC_2)
        ylabel('Engine RPM [rpm]')
        ylim([0 6000])
        
        %+++++ 2軸 +++++% Vehicle speed
        yyaxis right
        plot(saveTable{n,12}.time12,saveTable{n,12}.vVSP_ETKC_2)
        ylabel('Vehicle speed [km/h]')
        ylim([0 200])
        
        %+++++ 共通設定 +++++%
        xlim([xStart xEnd])
        xlabel('time [s]')
        box on
        grid on
        ax4.GridLineStyle = '--';
        
        %--------------- 5 個目 ---------------%
        ax5 = nexttile;
        
        %+++++ 1軸 +++++% λ
        yyaxis left
        plot(saveTable{n,10}.time10, saveTable{n,10}.vALPHA__0__ETKC_2)
        ylabel('λ [-]')
        ylim([0.5 1.5])
        
        %+++++ 2軸 +++++% Coolant temp.
        yyaxis right
        plot(saveTable{n,10}.time10, saveTable{n,10}.vTWN_ETKC_2)
        ylabel('Coolant temp. [℃]')
        ylim([0 100])
        
        %+++++ 共通設定 +++++%
        xlim([xStart xEnd])
        xlabel('time [s]')
        box on
        grid on
        ax5.GridLineStyle = '--';
        
        % グラフ横軸同期
        linkaxes([ax1, ax2, ax3, ax4, ax5], 'x')
    end
 
    %---------- 保存先設定, Figで保存 ----------%
%     figFullPath = fullfile(files(i).folder, figName);
%     savefig(strcat(figFullPath,'.fig'))
 
    %---------- 進捗通知 ----------%
    disp([' Done: ', num2str(i), ' / ', num2str(fileNum)])
    
end

% for i = 1:fileNum
%     %---------- matファイル 読み込み ----------%    
%     disp('File loading...')
%     load(fullfile(files(i).folder, files(i).name))
%     [~,figName,~] = fileparts(files(i).name);
% 
%     tableRow = height(saveTable);                               % saveTableの行数
%     for n = 1:tableRow                                          % saveTableの行数だけループ
%         if tableRow > 1                                         % 行数が2行以上なら
%             windowName = strcat(figName,'_',num2str(tableRow));    % Figureウインドウの表示名語尾に "_" と行数を追加
%             figure('Name', windowName);                             
%         end
%         figure('Name', figName);    
% 
%         %---------------<<< グラフ設定 >>>---------------%
%         tiledlayout(3,1)
%         %--------------- 1 個目 ---------------%
%         ax1 = nexttile;
%         
%         %+++++ 1軸 +++++% Zac
%         yyaxis left
%         plot(saveTable{n,8}.time8, saveTable{n,8}.vSF5ZAC_bios__0__ETKC_1)
%         ylabel('Zac [Ω]')
%         ylim([0 10000])
%         yticks(0:2500:10000)
%         
%         %+++++ 2軸 +++++% Duty
%         yyaxis right
%         plot(saveTable{n,8}.time8, saveTable{n,8}.vAFSHDTY__0__ETKC_1*100)
%         ylabel('Duty [%]')
%         ylim([0 100])
%         yticks(0:20:100)
%         
%         %+++++ 共通設定 +++++%
%         xlim([0 30])
%         xlabel('time [s]')
%         grid on
%         ax1.GridLineStyle = '--';
%         
%         %--------------- 2 個目 ---------------%
%     %     ax2 = nexttile;
%         
%         %+++++ 1軸 +++++% Convert temp.
%         % yyaxis left
%     %     yLow = yline(690, '-r','690℃');
%     %     yLow.LabelVerticalAlignment = 'bottom';
%     %     yHigh = yline(710, '-r','710℃');
%     %     
%     %     ylim([650 750])
%     %     ylabel('Element temp. [℃]')
%         
%         %+++++ 2軸 +++++% なし
%         % yyaxis right
%         
%         %+++++ 共通設定 +++++%
%     %     xlim([0 30])
%     %     xlabel('time [s]')
%     %     grid on
%     %     ax2.GridLineStyle = '--';
%     %     box on
%         
%         %--------------- 3 個目 ---------------%
%         ax3 = nexttile;
%         
%         %+++++ 1軸 +++++% Engine RPM
%         yyaxis left
%         plot(saveTable{n,7}.time7, saveTable{n,7}.vKNRPM_ETKC_1)
%         ylabel('Engine RPM [rpm]')
%         ylim([0 6000])
%         
%         %+++++ 2軸 +++++% Vehicle speed
%         yyaxis right
%         plot(saveTable{n,9}.time9,saveTable{n,9}.vVSP_ETKC_1)
%         ylabel('Vehicle speed [km/h]')
%         ylim([0 200])
%         
%         %+++++ 共通設定 +++++%
%         xlim([0 30])
%         xlabel('time [s]')
%         box on
%         grid on
%         ax3.GridLineStyle = '--';
%         
%         %--------------- 4 個目 ---------------%
%         ax4 = nexttile;
%         
%         %+++++ 1軸 +++++% λ
%         yyaxis left
%         plot(saveTable{n,7}.time7, saveTable{n,7}.vALPHA__0__ETKC_1)
%         ylabel('λ [-]')
%         ylim([0.5 1.5])
%         
%         %+++++ 2軸 +++++% Coolant temp.
%         yyaxis right
%         plot(saveTable{n,7}.time7, saveTable{n,7}.vTWN_ETKC_1)
%         ylabel('Coolant temp. [℃]')
%         ylim([0 100])
%         
%         %+++++ 共通設定 +++++%
%         xlim([0 30])
%         xlabel('time [s]')
%         box on
%         grid on
%         ax4.GridLineStyle = '--';
%         
%         % グラフ横軸同期
%         linkaxes([ax1, ax3, ax4], 'x')
%     end
%  
%     %---------- 保存先設定, Figで保存 ----------%
%     figFullPath = fullfile(files(i).folder, figName);
%     savefig(strcat(figFullPath,'.fig'))
%  
%     %---------- 進捗通知 ----------%
%     disp([' Done: ', num2str(i), ' / ', num2str(fileNum)])
% end

%% 終了メッセージ
%---------- 完了通知 ----------%    
disp('-----------------')
disp('~~~ Finish ~~~')
disp('-----------------')