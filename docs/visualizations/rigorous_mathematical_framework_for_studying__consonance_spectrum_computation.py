def consonance_spectrum(digits, N, center=4.5):
    return [sum((digits[i]-center)*(digits[i+k]-center) for i in range(N)) for k in range(13)]