pkg load signal
fs = 125e6/8; % 15,625 MHz
fc = 0.5e6; % coupure demandee a -6 dB
b = fir1(4, fc/(fs/2), 'low')
sum(b) % = 1 : gain unite en continu
freqz(b) % Bode : relever la frequence a -6 dB
