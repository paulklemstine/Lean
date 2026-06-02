def consonance_spectrum(digits, max_lag=12, center=4.5):
    return [(k, sum((digits[i]-center)*(digits[i+k]-center) for i in range(len(digits)-k)) / (len(digits)-k)) for k in range(max_lag+1)]