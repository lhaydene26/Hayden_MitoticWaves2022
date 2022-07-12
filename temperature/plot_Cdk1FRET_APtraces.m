    

% load the image data
% high temp embryos about 25 degrees
exp_date = '20191220B';
wave_frames = 480:520; % for 20191220B
t_trim = 10;

% low temp, about 14 degrees
% exp_date = '20200220';
% wave_frames = 1090:1260; % for 20200220
% t_trim = 80;

% low temp, about 13 degrees
% exp_date = '20200130B';
% wave_frames = 775:840;
% t_trim = 10;


% = 920:1050; % for 20200227
% t_trim = 70

load(strcat('D:\Luke\Projects\LDH006_FRET_sensor_temperature\microscopy\FRET-hom_his_unk\04_20x_air\',exp_date,'\stitched\',exp_date,'_data.mat'));
load(strcat('D:\Luke\Projects\LDH006_FRET_sensor_temperature\microscopy\FRET-hom_his_unk\04_20x_air\',exp_date,'\stitched\',exp_date,'_analysis.mat'));
load(strcat('D:\Luke\Projects\LDH006_FRET_sensor_temperature\microscopy\FRET-hom_his_unk\04_20x_air\',exp_date,'\stitched\',exp_date,'_aux.mat'));

cir = data.cir;
yfp = data.yfp;
mask_embryo = analysis.mask;
dt = aux.dt;

% calculate the FRET ratio over time, averaged over the entire embryo
FRETratio_whole = NaN(size(cir,3),1);
for j = 1:size(cir,3)
    temp_cir = cir(:,:,j);
    temp_yfp = yfp(:,:,j);
    FRETratio_whole(j) = nanmean(temp_yfp(mask_embryo)./temp_cir(mask_embryo));
end

% calculate Cdk1 FRET traces across the AP axis and over time
nbins = 20;
FRETratio_AP = NaN(numel(wave_frames), nbins);
for j = 1:numel(wave_frames)
    ssize = size(cir,2)/nbins;    
    for slice=1:nbins
        II = cir(:,ssize*(slice-1)+1:ssize*slice,wave_frames(j));
        II1 = yfp(:,ssize*(slice-1)+1:ssize*slice,wave_frames(j));
        BBW = mask_embryo(:,ssize*(slice-1)+1:ssize*slice);
        FRETratio_AP(j,slice) = sum(sum(double(II1(BBW>0))))/sum(sum(double(II(BBW>0))));
    end
end
for j = 1:numel(FRETratio_AP(1,:))
    FRETratio_AP(:,j) = FRETratio_AP(:,j)/nanmean(FRETratio_AP(:,j));
end
for j = 1:numel(FRETratio_AP(1,:))
    FRETratio_AP(:,j) = sgolayfilt(FRETratio_AP(:,j),3,15);
end


% plotting
t = numel(FRETratio_AP(:,1))-t_trim;

fig = figure;
step = 60/dt; % for 1 frame per minute
range = 1:step:t;
cmap = parula(numel(range));
colormap(cmap)
r = 4:16;
for j = 1:numel(range)
    f = FRETratio_AP(round(range(j)),r);
%     plot(sgolayfilt(f,3,5),'color',cmap(j,:),'LineWidth',2);
    plot(sgolayfilt(f-mean(f),3,5),'color',cmap(j,:),'LineWidth',2);
%                 pause
    hold on;
end
xlim([1, 13]);
xlabel('AP axis','FontSize',20);
xticks([1, 7, 13])
xticklabels({'0','0.5','1'})
ylabel('Emission ratio (a.u.)','FontSize',20)
legend off
colormap(cmap)
c = colorbar;
c.Label.String = 'Time (min.)';
c.Label.FontSize = 20;
c.Ticks = [0, 0.2, 0.4, 0.6, 0.8, 1];
c.TickLabels = floor(linspace(0, t*dt/60, 6));


ylim([-0.05, 0.05]);
% FigName = strcat('figures\Cdk1FRET_APtraces_',exp_date);
FigName = strcat('figures\Cdk1FRET_APtraces_',exp_date,'_normalized_difference');
standardizePlot_colorbar(gcf,gca,c,FigName);
close(fig);


