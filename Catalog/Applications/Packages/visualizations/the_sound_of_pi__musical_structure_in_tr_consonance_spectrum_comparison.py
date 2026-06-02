import math

def chromatic_freq(d):
    return 220.0 * (2.0 ** (d / 12.0))

def autocorr(digits, lag, center=4.5):
    n = len(digits) - lag
    if n <= 0: return 0.0
    return sum((digits[i]-center)*(digits[i+lag]-center) for i in range(n)) / n

def get_digits(name, n):
    try:
        from mpmath import mp, sqrt
        mp.dps = n + 50
        if name == 'pi': val = mp.pi
        elif name == 'e': val = mp.e
        elif name == 'sqrt2': val = sqrt(2)
        else: raise ValueError(name)
        s = mp.nstr(val, n+10).replace('.','')[1:n+1]
        return [int(c) for c in s]
    except ImportError:
        return [int(c) for c in '1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679'[:n]]

def main():
    try:
        import matplotlib; matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print('matplotlib not available'); return
    N = 10000
    names = ['Unison','m2','M2','m3','M3','P4','TT','P5','m6','M6','m7','M7','P8']
    fig, axes = plt.subplots(1,3,figsize=(18,6),sharey=True)
    for ax, (label,cname) in zip(axes, [('pi','pi'),('e','e'),('sqrt2','sqrt2')]):
        d = get_digits(cname, N)
        r = [autocorr(d,k) for k in range(13)]
        ax.bar(range(13), r, alpha=0.8)
        ax.set_title(f'Consonance Spectrum: {label}')
        ax.set_xticks(range(13)); ax.set_xticklabels(names, rotation=45, ha='right', fontsize=8)
        th = 1.96*math.sqrt(8.25/N)
        ax.axhline(th, color='r', ls='--', alpha=0.5); ax.axhline(-th, color='r', ls='--', alpha=0.5)
    axes[0].set_ylabel('Autocorrelation')
    plt.tight_layout(); plt.savefig('consonance_spectrum.png', dpi=150, bbox_inches='tight')
    print('Saved consonance_spectrum.png')

if __name__ == '__main__': main()