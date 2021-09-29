clear all
clc
%% set the orchestra sections
%4 sections: violin1, violin2, cello, wind
%chamber orchestra size: each section, 5 people
%two most significant figures: concertmaster & conductor
%each player will have a within-group alpha value, zeros for the
%other sections and a large alpha value for the conductor, except
%from the violins sections which will have the same for the concertmaster as well

period=1; %metronome, beat
%% conductor
selfCorrection=0.9;
alpha=[selfCorrection zeros(1,5) zeros(1,5) zeros(1,5) zeros(1,5) 0];
stdError=0.001;
initialTime=0;
conductor=clappingAgent(alpha,stdError,period);
conductor=setClapTime(conductor,initialTime);

%% concertmaster
alpha=[0 zeros(1,5) zeros(1,5) zeros(1,5) zeros(1,5) 0.5]; %corrects only in respect with the conductor
stdError=0.01;
initialTime=0.3;
concertmaster=clappingAgent(alpha,stdError,period);
concertmaster=setClapTime(concertmaster,initialTime);

%% violin1 section
withinGroup=(0.5-0.01)*rand(1,4)+0.01;
%[metronome, violin1, concertmaster, violin2, cello, wind, conductor]
alpha = [0 withinGroup 0.5 zeros(1,5) zeros(1,5) zeros(1,5) 0.5]; 
stdPlayingError=rand(1,4)/10;
initialPlayTime=0.3;
violin1=clappingAgent.empty(4,0);
for p = 1:4
    violin=clappingAgent(alpha,stdPlayingError(p),period);
    violin=setClapTime(violin,initialPlayTime);
    violin1(p)=violin;
end

%% violin2 section
withinGroup=(0.5-0.01)*rand(1,5)+0.01;
alpha = [0 zeros(1,4) 0.5 withinGroup zeros(1,5) zeros(1,5) 0.5]; 
stdPlayingError=rand(1,5)/10;
initialPlayTime=0.5;
violin2=clappingAgent.empty(5,0);
for p = 1:5
    violin=clappingAgent(alpha,stdPlayingError(p),period);
    violin=setClapTime(violin,initialPlayTime);
    violin2(p)=violin;
end

%% cello section
withinGroup=(0.5-0.01)*rand(1,5)+0.01;
alpha = [0 zeros(1,5) zeros(1,5) withinGroup zeros(1,5) 0.5];
stdPlayingError=rand(1,5)/10;
initialPlayTime=0.5;
cello=clappingAgent.empty(5,0);
for p = 1:5
    cel=clappingAgent(alpha,stdPlayingError(p),period);
    cel=setClapTime(cel,initialPlayTime);
    cello(p)=cel;
end

%% wind section
withinGroup=(0.5-0.01)*rand(1,5)+0.01;
alpha = [0 zeros(1,5) zeros(1,5) zeros(1,5) withinGroup 0.5];
stdPlayingError=rand(1,5)/10;
initialPlayTime=1;
wind=clappingAgent.empty(5,0);
for p = 1:5
    w=clappingAgent(alpha,stdPlayingError(p),period);
    w=setClapTime(w,initialPlayTime);
    wind(p)=w;
end

%% initialisation of variables
numberOfBars = 20;
violin1Async = zeros(4,21,numberOfBars); %
violin2Async = zeros(5,21,numberOfBars);
celloAsync = zeros(5,21,numberOfBars);
windAsync = zeros(5,21,numberOfBars);
concertmasterAsync = zeros(1,21,numberOfBars);
conductorAsync = zeros(1,21,numberOfBars);
error = zeros(21,numberOfBars);

%% do string sections perform better by taking into account both the concertmaster and the conductor?
%3 scenarios: 1)concertmaster=conductor weight, 2)concertmaster>conductor,
%3)concertmaster<conductor, the values will be changed in the corresponding
%section and calculations & plotting will be done here
notesTime=zeros(5,5);
for bar = 1:numberOfBars
    for i = 1:5
        if i<5
            notesTime(1,i)=getClapTime(violin1(1,i));
        else
            notesTime(1,5)=getClapTime(concertmaster);
        end
        notesTime(2,i)=getClapTime(violin2(1,i));
        notesTime(3,i)=getClapTime(cello(1,i));
        notesTime(4,i)=getClapTime(wind(1,i));
    end
    notesTime(5,1)=getClapTime(conductor);
    error(1:4,bar)=notesTime(1,1:4)-period*(bar-1);
    error(5,bar)=notesTime(1,5)-period*(bar-1);
    error(6:10,bar)=notesTime(2,:)-period*(bar-1);
    error(11:15,bar)=notesTime(3,:)-period*(bar-1);
    error(16:20,bar)=notesTime(4,:)-period*(bar-1);
    error(21,bar)=notesTime(5,1)-period*(bar-1);
    %violin1 asynchronies
    for a1=1:4
        for a2=1:21
            if a2<6
                violin1Async(a1,a2,bar)=notesTime(1,a1)-notesTime(1,a2);
            elseif a2<11
                violin1Async(a1,a2,bar)=notesTime(1,a1)-notesTime(2,a2-5);
            elseif a2<16
                violin1Async(a1,a2,bar)=notesTime(1,a1)-notesTime(3,a2-10);
            elseif a2<21
                violin1Async(a1,a2,bar)=notesTime(1,a1)-notesTime(4,a2-15);
            else
                violin1Async(a1,a2,bar)=notesTime(1,a1)-notesTime(5,1);
            end
        end
    end
    %violin2 asynchronies
    for a1=1:5
        for a2=1:21
            if a2<6
                violin2Async(a1,a2,bar)=notesTime(2,a1)-notesTime(1,a2);
            elseif a2<11
                violin2Async(a1,a2,bar)=notesTime(2,a1)-notesTime(2,a2-5);
            elseif a2<16
                violin2Async(a1,a2,bar)=notesTime(2,a1)-notesTime(3,a2-10);
            elseif a2<21
                violin2Async(a1,a2,bar)=notesTime(2,a1)-notesTime(4,a2-15);
            else
                violin2Async(a1,a2,bar)=notesTime(2,a1)-notesTime(5,1);
            end
        end
    end
    %cello asynchronies
    for a1=1:5
        for a2=1:21
            if a2<6
                celloAsync(a1,a2,bar)=notesTime(3,a1)-notesTime(1,a2);
            elseif a2<11
                celloAsync(a1,a2,bar)=notesTime(3,a1)-notesTime(2,a2-5);
            elseif a2<16
                celloAsync(a1,a2,bar)=notesTime(3,a1)-notesTime(3,a2-10);
            elseif a2<21
                celloAsync(a1,a2,bar)=notesTime(3,a1)-notesTime(4,a2-15);
            else
                celloAsync(a1,a2,bar)=notesTime(3,a1)-notesTime(5,1);
            end
        end
    end
    %wind asynchronies
    for a1=1:5
        for a2=1:21
            if a2<6
                windAsync(a1,a2,bar)=notesTime(4,a1)-notesTime(1,a2);
            elseif a2<11
                windAsync(a1,a2,bar)=notesTime(4,a1)-notesTime(2,a2-5);
            elseif a2<16
                windAsync(a1,a2,bar)=notesTime(4,a1)-notesTime(3,a2-10);
            elseif a2<21
                windAsync(a1,a2,bar)=notesTime(4,a1)-notesTime(4,a2-15);
            else
                windAsync(a1,a2,bar)=notesTime(4,a1)-notesTime(5,1);
            end
        end
    end
    %concertmaster asynchronies
    for a=1:21
        if a<6
            concertmasterAsync(1,a,bar)=notesTime(1,5)-notesTime(1,a);
        elseif a<11
            concertmasterAsync(1,a,bar)=notesTime(1,5)-notesTime(2,a-5);
        elseif a<16
            concertmasterAsync(1,a,bar)=notesTime(1,5)-notesTime(3,a-10);
        elseif a<21
            concertmasterAsync(1,a,bar)=notesTime(1,5)-notesTime(4,a-15);
        else
            concertmasterAsync(1,a,bar)=notesTime(1,5)-notesTime(5,1);
        end
    end
    %conductor asynchronies
    for a=1:21
        if a<6
            conductorAsync(1,a,bar)=notesTime(5,1)-notesTime(1,a);
        elseif a<11
            conductorAsync(1,a,bar)=notesTime(5,1)-notesTime(2,a-5);
        elseif a<16
            conductorAsync(1,a,bar)=notesTime(5,1)-notesTime(3,a-10);
        elseif a<21
            conductorAsync(1,a,bar)=notesTime(5,1)-notesTime(4,a-15);
        else
            conductorAsync(1,a,bar)=notesTime(5,1)-notesTime(5,1);
        end
    end 
    %play next bar
    for i=1:4
        violin1(1,i)=playClap(violin1(1,i),[error(i,bar) squeeze(violin1Async(i,:,bar))]);
    end
    concertmaster=playClap(concertmaster,[error(5,bar) squeeze(concertmasterAsync(1,:,bar))]);
    for i=1:5
        violin2(1,i)=playClap(violin2(1,i),[error(i+5,bar) squeeze(violin2Async(i,:,bar))]);
    end
    for i=1:5
        cello(1,i)=playClap(cello(1,i),[error(i+10,bar) squeeze(celloAsync(i,:,bar))]);
    end
    for i=1:5
        wind(1,i)=playClap(wind(1,i),[error(i+15,bar) squeeze(windAsync(i,:,bar))]);
    end
    conductor=playClap(conductor,[error(21,bar) squeeze(conductorAsync(1,:,bar))]);
end
%% plotting
fig = figure(1);
for i=1:4
    subplot(4,1,i), plot(squeeze(violin1Async(i,:,:))')
    legend
end
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Asynchronies');
xlabel(han,'Music bars');
title(han,'Violin 1 section (without concertmaster)');

fig = figure(2);
for i=1:5
    subplot(5,1,i), plot(squeeze(violin2Async(i,:,:))')
end
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Asynchronies');
xlabel(han,'Music bars');
title(han,'Violin 2 section');

fig = figure(3);
for i=1:5
    subplot(5,1,i), plot(squeeze(celloAsync(i,:,:))')
end
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Asynchronies');
xlabel(han,'Music bars');
title(han,'Cello section');

fig = figure(4);
for i=1:5
    subplot(5,1,i), plot(squeeze(windAsync(i,:,:))')
end
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Asynchronies');
xlabel(han,'Music bars');
title(han,'Wind section');

fig = figure(5);
subplot(2,1,1), plot(squeeze(concertmasterAsync(1,:,:))')
subplot(2,1,2), plot(squeeze(conductorAsync(1,:,:))')
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Asynchronies');
xlabel(han,'Music bars');
title(han,'Concertmaster (top), Conductor (bottom)');
%% if we remove the conductor, does the orchestra's performance change? is it better if they adapt their weights?
notesTime=zeros(5,5);
for bar = 1:numberOfBars
    if bar==15
        alpha=[0 zeros(1,5) zeros(1,5) zeros(1,5) zeros(1,5) 0];
        concertmaster=setAlpha(concertmaster,alpha);
        alpha=violin1(1,1).alpha;
        alpha(1,22)=0;
        for i=1:4
            violin1(1,i)=setAlpha(violin1(1,i),alpha);
        end
        alpha=violin2(1,1).alpha;
        alpha(1,22)=0;
        for i=1:5
            violin2(1,i)=setAlpha(violin2(1,i),alpha);
        end
        alpha=cello(1,1).alpha;
        alpha(1,22)=0;
        for i=1:5
            cello(1,i)=setAlpha(cello(1,i),alpha);
        end
        alpha=wind(1,1).alpha;
        alpha(1,22)=0;
        for i=1:5
            wind(1,i)=setAlpha(wind(1,i),alpha);
        end
        for i = 1:5
            if i<5
                notesTime(1,i)=getClapTime(violin1(1,i));
            else
                notesTime(1,5)=getClapTime(concertmaster);
            end
            notesTime(2,i)=getClapTime(violin2(1,i));
            notesTime(3,i)=getClapTime(cello(1,i));
            notesTime(4,i)=getClapTime(wind(1,i));
        end
    else
        for i = 1:5
            if i<5
                notesTime(1,i)=getClapTime(violin1(1,i));
            else
                notesTime(1,5)=getClapTime(concertmaster);
            end
            notesTime(2,i)=getClapTime(violin2(1,i));
            notesTime(3,i)=getClapTime(cello(1,i));
            notesTime(4,i)=getClapTime(wind(1,i));
        end
        notesTime(5,1)=getClapTime(conductor);
    end
    error(1:4,bar)=notesTime(1,1:4)-period*(bar-1);
    error(5,bar)=notesTime(1,5)-period*(bar-1);
    error(6:10,bar)=notesTime(2,:)-period*(bar-1);
    error(11:15,bar)=notesTime(3,:)-period*(bar-1);
    error(16:20,bar)=notesTime(4,:)-period*(bar-1);
    if bar<15
        error(21,bar)=notesTime(5,1)-period*(bar-1);
    end
    %violin1 asynchronies
    for a1=1:4
        for a2=1:21
            if a2<6
                violin1Async(a1,a2,bar)=notesTime(1,a1)-notesTime(1,a2);
            elseif a2<11
                violin1Async(a1,a2,bar)=notesTime(1,a1)-notesTime(2,a2-5);
            elseif a2<16
                violin1Async(a1,a2,bar)=notesTime(1,a1)-notesTime(3,a2-10);
            elseif a2<21
                violin1Async(a1,a2,bar)=notesTime(1,a1)-notesTime(4,a2-15);
            else
                if bar<15
                    violin1Async(a1,a2,bar)=notesTime(1,a1)-notesTime(5,1);
                end
            end
        end
    end
    %violin2 asynchronies
    for a1=1:5
        for a2=1:21
            if a2<6
                violin2Async(a1,a2,bar)=notesTime(2,a1)-notesTime(1,a2);
            elseif a2<11
                violin2Async(a1,a2,bar)=notesTime(2,a1)-notesTime(2,a2-5);
            elseif a2<16
                violin2Async(a1,a2,bar)=notesTime(2,a1)-notesTime(3,a2-10);
            elseif a2<21
                violin2Async(a1,a2,bar)=notesTime(2,a1)-notesTime(4,a2-15);
            else
                if bar<15
                    violin2Async(a1,a2,bar)=notesTime(2,a1)-notesTime(5,1);
                end
            end
        end
    end
    %cello asynchronies
    for a1=1:5
        for a2=1:21
            if a2<6
                celloAsync(a1,a2,bar)=notesTime(3,a1)-notesTime(1,a2);
            elseif a2<11
                celloAsync(a1,a2,bar)=notesTime(3,a1)-notesTime(2,a2-5);
            elseif a2<16
                celloAsync(a1,a2,bar)=notesTime(3,a1)-notesTime(3,a2-10);
            elseif a2<21
                celloAsync(a1,a2,bar)=notesTime(3,a1)-notesTime(4,a2-15);
            else
                if bar<15
                    celloAsync(a1,a2,bar)=notesTime(3,a1)-notesTime(5,1);
                end
            end
        end
    end
    %wind asynchronies
    for a1=1:5
        for a2=1:21
            if a2<6
                windAsync(a1,a2,bar)=notesTime(4,a1)-notesTime(1,a2);
            elseif a2<11
                windAsync(a1,a2,bar)=notesTime(4,a1)-notesTime(2,a2-5);
            elseif a2<16
                windAsync(a1,a2,bar)=notesTime(4,a1)-notesTime(3,a2-10);
            elseif a2<21
                windAsync(a1,a2,bar)=notesTime(4,a1)-notesTime(4,a2-15);
            else
                if bar<15
                    windAsync(a1,a2,bar)=notesTime(4,a1)-notesTime(5,1);
                end
            end
        end
    end
    %concertmaster asynchronies
    for a=1:21
        if a<6
            concertmasterAsync(1,a,bar)=notesTime(1,5)-notesTime(1,a);
        elseif a<11
            concertmasterAsync(1,a,bar)=notesTime(1,5)-notesTime(2,a-5);
        elseif a<16
            concertmasterAsync(1,a,bar)=notesTime(1,5)-notesTime(3,a-10);
        elseif a<21
            concertmasterAsync(1,a,bar)=notesTime(1,5)-notesTime(4,a-15);
        else
            if bar<15
                concertmasterAsync(1,a,bar)=notesTime(1,5)-notesTime(5,1);
            end
        end
    end
    if bar<15
        %conductor asynchronies
        for a=1:21
            if a<6
                conductorAsync(1,a,bar)=notesTime(5,1)-notesTime(1,a);
            elseif a<11
                conductorAsync(1,a,bar)=notesTime(5,1)-notesTime(2,a-5);
            elseif a<16
                conductorAsync(1,a,bar)=notesTime(5,1)-notesTime(3,a-10);
            elseif a<21
                conductorAsync(1,a,bar)=notesTime(5,1)-notesTime(4,a-15);
            else
                conductorAsync(1,a,bar)=notesTime(5,1)-notesTime(5,1);
            end
        end 
    end
    %play next bar
    for i=1:4
        violin1(1,i)=playClap(violin1(1,i),[error(i,bar) squeeze(violin1Async(i,:,bar))]);
    end
    concertmaster=playClap(concertmaster,[error(5,bar) squeeze(concertmasterAsync(1,:,bar))]);
    for i=1:5
        violin2(1,i)=playClap(violin2(1,i),[error(i+5,bar) squeeze(violin2Async(i,:,bar))]);
    end
    for i=1:5
        cello(1,i)=playClap(cello(1,i),[error(i+10,bar) squeeze(celloAsync(i,:,bar))]);
    end
    for i=1:5
        wind(1,i)=playClap(wind(1,i),[error(i+15,bar) squeeze(windAsync(i,:,bar))]);
    end
    if bar<15
        conductor=playClap(conductor,[error(21,bar) squeeze(conductorAsync(1,:,bar))]);
    end
end
%% plotting
fig = figure(1);
for i=1:4
    subplot(4,1,i), plot(squeeze(violin1Async(i,:,:))')
end
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Asynchronies');
xlabel(han,'Music bars');
title(han,'Violin 1 section (without concertmaster)');

fig = figure(2);
for i=1:5
    subplot(5,1,i), plot(squeeze(violin2Async(i,:,:))')
end
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Asynchronies');
xlabel(han,'Music bars');
title(han,'Violin 2 section');

fig = figure(3);
for i=1:5
    subplot(5,1,i), plot(squeeze(celloAsync(i,:,:))')
end
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Asynchronies');
xlabel(han,'Music bars');
title(han,'Cello section');

fig = figure(4);
for i=1:5
    subplot(5,1,i), plot(squeeze(windAsync(i,:,:))')
end
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Asynchronies');
xlabel(han,'Music bars');
title(han,'Wind section');

fig = figure(5);
subplot(2,1,1), plot(squeeze(concertmasterAsync(1,:,:))')
subplot(2,1,2), plot(squeeze(conductorAsync(1,:,:))')
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Asynchronies');
xlabel(han,'Music bars');
title(han,'Concertmaster (top), Conductor (bottom)');