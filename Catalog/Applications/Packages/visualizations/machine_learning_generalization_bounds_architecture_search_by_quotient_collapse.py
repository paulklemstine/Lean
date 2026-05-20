import math

def architecture_search(n, epsilon, param_dims, delta=0.05, max_q=20, max_c=10):
    """Search for architectures that generalize at target accuracy."""
    budget = n * epsilon ** 2
    kl = math.log(1.0 / delta)
    results = []
    for d in param_dims:
        for q in range(0, min(max_q + 1, d + 1)):
            for c in range(0, min(max_c + 1, d + 1)):
                eff = q + c + kl
                if eff <= budget:
                    results.append({'params': d, 'q': q, 'c': c,
                                   'eff': eff, 'ratio': d / max(eff, 0.01)})
    results.sort(key=lambda x: -x['ratio'])
    for r in results[:5]:
        print(f"params={r['params']:>8}, q={r['q']}, c={r['c']}, "
              f"eff={r['eff']:.1f}, compression={r['ratio']:.0f}x")
    return results[:5]

architecture_search(5000, 0.1, [100, 1000, 10000])