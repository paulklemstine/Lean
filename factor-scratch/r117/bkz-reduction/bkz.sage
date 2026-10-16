load("lib.sage")
# Does BETTER REDUCTION lower the threshold? The round-117 embedding sweep concluded the
# residual 12.5% overhead is a reduction-quality limit. That claim is only useful if it is
# measured. Sweep reduction strength at fixed (nbits, t) and report the first l with rate
# >= 10/12, always beside the LLL baseline measured in the same harness.
import time

def threshold(nbits, t, dbits, algo, block=None, seeds=12, step=None):
    step = step or max(1, nbits // 16)
    for l in range(0, nbits + 1, step):
        h = 0; t0 = time.time()
        for sd in range(seeds):
            inst = build_instance(nbits, t, l, "msb", sd=sd, dbits=dbits)
            h += (attack(inst, algo=algo, bkz_block=block)[0] is not None)
        el = time.time() - t0
        if h >= 10:
            return l, h, el
    return None, 0, 0.0

print("== nbits=128, t=4 (dim 5) : threshold l* by reduction strength ==", flush=True)
print(f"{'algo':>10} {'block':>6} | {'l*':>5} {'t*l*':>6} {'ratio':>6} {'time/12':>9}", flush=True)
for algo, block in [("lll", None), ("bkz", 8), ("bkz", 10), ("bkz", 14), ("bkz", 20), ("bkz", 30)]:
    lstar, h, el = threshold(128, 4, 128, algo, block)
    ratio = (4*lstar/128) if lstar else None
    print(f"{algo:>10} {str(block):>6} | {str(lstar):>5} {str(4*lstar if lstar else None):>6} "
          f"{('%.3f' % ratio) if ratio else '     -':>6} {el:>8.1f}s", flush=True)

print("== nbits=256, t=4 (dim 5) : same, at the real scale ==", flush=True)
print(f"{'algo':>10} {'block':>6} | {'l*':>5} {'t*l*':>6} {'ratio':>6} {'time/12':>9}", flush=True)
for algo, block in [("lll", None), ("bkz", 10), ("bkz", 20), ("bkz", 30), ("bkz", 40)]:
    lstar, h, el = threshold(256, 4, 256, algo, block, step=8)
    ratio = (4*lstar/256) if lstar else None
    print(f"{algo:>10} {str(block):>6} | {str(lstar):>5} {str(4*lstar if lstar else None):>6} "
          f"{('%.3f' % ratio) if ratio else '     -':>6} {el:>8.1f}s", flush=True)
