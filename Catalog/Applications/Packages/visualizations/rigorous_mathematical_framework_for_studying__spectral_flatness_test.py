def spectral_flatness_test(digits, N, max_lag=12):
    spectra = {k: {t: c/N for t, c in transition_spectrum(digits, N, k).items()} for k in range(1, max_lag+1)}
    max_dev = max(abs(spectra[k1].get(t,0)-spectra[k2].get(t,0)) for k1 in spectra for k2 in spectra if k1<k2 for t in set(spectra[k1])|set(spectra[k2]))
    return max_dev