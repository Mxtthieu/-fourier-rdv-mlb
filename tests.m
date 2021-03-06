% is me

function my_tests()
% calcul des descripteurs de Fourier de la base de données
img_db_path = './db/';
img_db_list = glob([img_db_path, '*.gif']);
img_db = cell(1);
label_db = cell(1);
fd_db = cell(1);
for im = 1:numel(img_db_list);
    img_db{im} = logical(imread(img_db_list{im}));
    label_db{im} = get_label(img_db_list{im});
    disp(label_db{im}); 
    [fd_db{im},~,~,~] = compute_fd(img_db{im});
end

% importation des images de requête dans une liste
img_path = './dbq/';
img_list = glob([img_path, '*.gif']);
t=tic()

% pour chaque image de la liste...
for im = 1:numel(img_list)
   
    % calcul du descripteur de Fourier de l'image
    img = logical(imread(img_list{im}));
    [fd,r,m,poly] = compute_fd(img);
       
    % calcul et tri des scores de distance aux descripteurs de la base
    for i = 1:length(fd_db)
        scores(i) = norm(fd-fd_db{i});
    end
    [scores, I] = sort(scores);
       
    % affichage des résultats    
    close all;
    figure(1);
    top = 5; % taille du top-rank affiché
    subplot(2,top,1);
    imshow(img); hold on;
    plot(m(1),m(2),'+b'); % affichage du barycentre
    plot(poly(:,1),poly(:,2),'v-g','MarkerSize',1,'LineWidth',1); % affichage du contour calculé
    subplot(2,top,2:top);
    plot(r); % affichage du profil de forme
    for i = 1:top
        subplot(2,top,top+i);
        imshow(img_db{I(i)}); % affichage des top plus proches images
    end
    drawnow();
    waitforbuttonpress();
end
end

function [fd,r,m,poly] = compute_fd(img)
N = 500; % modifié
M = 500; % modifié
h = size(img,1);
w = size(img,2);
[col,row] = find(img>0); % pixels blancs
baryX = mean(col); % definition barycentre 
baryY = mean(row); 
m = [baryY, baryX]; % modifié
t = linspace(0,2*pi,N);
dMax = min(max(col),max(row)); % distance max
R = ones(1,length(t))*dMax/20;
mErr = dMax/10; % marge d'erreur
% On garde la couleur du point de début de l'algo
spawn = img(max(1,min(h,floor(baryX))), max(1,min(w,floor(baryY))));  
poly = [];

for i = 1:length(t)  
    rayon = R(i);
    while (floor((baryX+(R(i)*sin(t(i)))))>0 && floor((baryY+R(i)*-cos(t(i))))>0 && floor((baryY+R(i)*-cos(t(i))))<w && floor((baryX+(R(i)*sin(t(i)))))<h &&img( floor((baryX+(R(i)*sin(t(i))))), floor((baryY+R(i)*-cos(t(i))))) ==spawn) ||  ( floor((baryX+((R(i)+mErr)*sin(t(i)))))>0 && floor((baryY+(R(i)+mErr)*-cos(t(i))))>0 && floor((baryY+(R(i)+mErr)*-cos(t(i))))<w && floor((baryX+((R(i)+mErr)*sin(t(i)))))<h &&img( floor((baryX+((R(i)+mErr)*sin(t(i))))), floor((baryY+(R(i)+mErr)*-cos(t(i))))) ==spawn)
            R(i)=1+R(i);  
            rayon = (R(i)+1);
    end
end  

poly = ones(length(R),2);

for i = 1:length(R-1) 
%Tracage de la ligne
poly(i,:) = [(R(i)*-cos(t(i))+baryY),(R(i)*sin(t(i))+baryX)];  
end 

r = R;
%Calcul de la TF
rf_r0 = abs(R)/abs(R(1));
fd = fft(rf_r0(1:M)); 

end
