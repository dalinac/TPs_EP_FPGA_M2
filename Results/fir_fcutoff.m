pkg load signal
fs = 125e6/8;
fc = 0.5e6; % coupure demandee a -6 dB
b = fir1(4, fc/(fs/2), 'low')
sum(b)
freqz(b) % Bode : relever la frequence a -6 dB

% ---------------------------------------------------------------
% De la frequence lue sur le graphe a la frequence reelle
%
% freqz trace l'axe x en frequence NORMALISEE wn, qui va de 0 a 1 :
% la valeur 1 correspond a pi rad/echantillon, c'est-a-dire a fs/2.
% Pour convertir une valeur lue sur cet axe :
%
%        f = wn * fs/2        avec fs/2 = 7,8125 MHz
%
% ex : au point -6 dB on lit wn = 0,4238
%      f = 0,4238 * 7,8125e6 = 3,31 MHz  (et non 0,5 MHz)
% ---------------------------------------------------------------

