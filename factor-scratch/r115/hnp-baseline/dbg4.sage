load("hnp_baseline_lib.sage")
import time
print("degenerate l=0 (must NOT recover):", [attack(build_instance(96,4,0,"msb",sd=sd))[0] is not None for sd in range(6)])
print("heavy leak 96/4/64 (must recover):",  [attack(build_instance(96,4,64,"msb",sd=sd))[0] is not None for sd in range(6)])
print("heavy leak 64/4/32 (must recover):",  [attack(build_instance(64,4,32,"msb",sd=sd))[0] is not None for sd in range(6)])
print("light 96/4/32 t*l=128>96 (recover?):", [attack(build_instance(96,4,32,"msb",sd=sd))[0] is not None for sd in range(6)])
t0=time.time(); attack(build_instance(160,4,96,"msb",sd=0)); print("160-bit instance time:", round(time.time()-t0,3))
