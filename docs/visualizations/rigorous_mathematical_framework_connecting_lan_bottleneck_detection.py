def find_bottleneck(h):
    ev = [max(0.0, h[i] - h[i+1]) for i in range(len(h)-1)]
    idx = max(range(len(ev)), key=lambda i: ev[i])
    return (idx, ev[idx])