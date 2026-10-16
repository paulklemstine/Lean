load("hnp_baseline_lib.sage")
print("--- degenerate l=0 case, must NOT recover:")
for sd in range(6):
    inst = build_instance(96, 4, 0, "msb", sd=sd)
    dd, w, st = attack(inst)
    print(f"  seed {sd}: recovered={dd is not None} (expect False)")
print("--- heavy leakage, must recover:")
for sd in range(6):
    inst = build_instance(96, 4, 64, "msb", sd=sd)
    dd, w, st = attack(inst)
    print(f"  seed {sd}: recovered={dd is not None} (expect True)")
