load("hnp_baseline_lib.sage")
# SECOND INDEPENDENT RUN of the headline cells (campaign rule: every count twice)
cells = [(64,2,33),(64,2,32),(96,4,28),(128,4,36),(128,4,32),(192,8,27),(256,4,72),(256,4,64)]
for nb,t,l in cells:
    h = 0
    for sd in range(12):
        h += attack(build_instance(nb,t,l,"msb",sd=sd))[0] is not None
    print(f"RUN2 nbits={nb:3d} t={t:2d} l={l:3d} t*l={t*l:4d} floor={nb:3d} rate={h}/12", flush=True)
