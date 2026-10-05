# Falsifier for the HARNESS_AUDIT claim that gifp.sage's seed overwrite is
# the cause of non-reproducibility.  load() applies the preparser, so both
# copies are byte-identical to the original except the one patched line.
import logging
logging.disable(logging.CRITICAL)
load('/home/raver1975/lean/factor-scratch/r114/infra/_gifp_orig.sage')
ORIG = globals()['generate_gifp_instance']
load('/home/raver1975/lean/factor-scratch/r114/infra/_gifp_fixed.sage')
FIX = globals()['generate_gifp_instance']

print("=== FALSIFIER: is line 49 the cause? ===")
for name, gen in [('ORIGINAL        (seed = int(time.time()*1e6))', ORIG),
                  ('PATCHED         (seed = seed + attempts)     ', FIX)]:
    Ns = []
    for _ in range(4):
        r = gen(200, 0.1, 0.1, 0.1, 0.2, seed=12345, max_attempts=10)
        Ns.append(r[0][2])
    same = len(set(Ns)) == 1
    print("  %s" % name)
    print("    4 trials @ seed=12345 -> %s" % ("IDENTICAL" if same else "DIFFER (%d distinct of 4)" % len(set(Ns))))
    for i, N in enumerate(Ns):
        print("      trial %d: N1 = ...%d" % (i, N % 10**12))
