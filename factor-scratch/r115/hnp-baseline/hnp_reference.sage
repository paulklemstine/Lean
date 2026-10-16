# Reference harness for the ECDSA HNP lattice baseline. Definitions live in
# hnp_baseline_lib.sage (loaded with Sage's preparser-aware `load`).
load("hnp_baseline_lib.sage")
print("fpylll available:", HAVE_FPYLLL, file=sys.stderr)
_what = sys.argv[1] if len(sys.argv) > 1 else "control"

if _what == "control":
    seeds = 12
    hits = 0
    for sd in range(seeds):
        inst = build_instance(64, 4, 40, "msb", sd=sd)
        dd, wrong, st = attack(inst)
        hits += (dd is not None)
    print(f"POSITIVE CONTROL nbits=64 t=4 l=40 (t*l=160 vs log2 n=64): {hits}/{seeds}", flush=True)
    # a second control at a different size and with LSB leakage
    hits2 = 0
    for sd in range(seeds):
        inst = build_instance(80, 6, 24, "lsb", sd=sd)
        dd, wrong, st = attack(inst)
        hits2 += (dd is not None)
    print(f"POSITIVE CONTROL nbits=80 t=6 l=24 lsb (t*l=144 vs log2 n=80): {hits2}/{seeds}", flush=True)

elif _what == "realcurve":
    real_curve()

elif _what == "sweep":
    nbits_list = [int(x) for x in sys.argv[2].split(",")]
    t_list = [int(x) for x in sys.argv[3].split(",")]
    mode = sys.argv[4] if len(sys.argv) > 4 else "msb"
    seeds = int(sys.argv[5]) if len(sys.argv) > 5 else 12
    rows = []
    for nbits in nbits_list:
        for t in t_list:
            step = max(1, nbits // 12)
            for l in range(0, nbits + 1, step):
                hits = 0; wrong = 0; t0 = time.time()
                for sd in range(seeds):
                    inst = build_instance(nbits, t, l, mode, sd=sd)
                    dd, w, st = attack(inst, algo=("bkz" if nbits <= 128 else "lll"))
                    hits += (dd is not None); wrong += w
                el = time.time() - t0
                rows.append(dict(nbits=nbits, t=t, l=l, leak_bits=t * l,
                                 hits=hits, seeds=seeds, wrong=wrong,
                                 secs=round(el, 2), mode=mode))
                print(f"{'HIT ' if hits else '    '} nbits={nbits:4d} t={t:2d} l={l:4d} "
                      f"t*l={t*l:5d} floor={nbits:4d} rate={hits}/{seeds} "
                      f"wrong={wrong} {el:.1f}s", flush=True)
    json.dump(rows, open(f"sweep_{mode}_{'_'.join(map(str,nbits_list))}.json", "w"), indent=1)
