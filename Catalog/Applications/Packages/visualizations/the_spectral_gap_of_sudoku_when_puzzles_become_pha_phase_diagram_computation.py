def compute_phase_diagram(gap_fn, dc, df, n=100):
    results = []
    for i in range(n+1):
        d = i / n
        gap = max(0, gap_fn(d))
        phase = 'sub' if d < dc else ('crit' if d < df else 'super')
        results.append((d, gap, phase))
    return results