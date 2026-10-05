#!/usr/bin/env python3
"""
THE DECISIVE CALCULATION.
Hypothesis: fuse yoked cold storage into Pinnacle's rho-parallelised memory.
The fusion would be worth something ONLY if Pinnacle's memory were the
density bottleneck, i.e. if the yoked code made the MEMORY cheaper.
All numbers FETCHED (Pinnacle Table I + Sec V.B.3, verbatim below).
"""
print("=== Pinnacle's OWN memory density (Table I, fetched verbatim) ===")
# Table I: J_{n,k,dK}, code block qubits ncb=2n, processing block npb = ncb+4ng+4nb
tab = [("J30,8,4K",30,8,60,13,7,140),("J62,10,6K",62,10,124,19,11,244),
       ("J126,12,10K",126,12,252,31,19,452),("J254,14,16K",254,14,508,57,31,860)]
print(f"  {'code':14s} {'ncb=2n':>7s} {'k':>4s} {'k/ncb':>7s} {'phys/logical':>14s}")
for name,n,k,ncb,ng,nb,npb in tab:
    rate = k/ncb
    print(f"  {name:14s} {ncb:7d} {k:4d} {rate:7.3f} {ncb/k:14.1f}")
print()
print("  VERBATIM (Pinnacle p, Sec V.B.3 / Table I footnote):")
print("   'ncb = 2n',  'npb = ncb + 4ng + 4nb'")
print("   'we can encode 14nu logical qubits in memory such that rho processing")
print("    units can access it in parallel with 508nu + 88rho physical qubits at d = 16'")
print()
print("=== THE FUSION TEST ===")
q_cold = 430     # Gidney p18, yoked 2D cold
q_std  = 1352    # Gidney p18, hot patch 2*(25+1)^2
# J254 at d=16 -> 508 phys per code block, 14 logical
pin_mem = 508/14
print(f"  Pinnacle memory:        {pin_mem:6.1f} phys/logical  (J254, 14 logical in 508 qubits)")
print(f"  Gidney yoked COLD:      {q_cold:6.1f} phys/logical")
print(f"  Gidney hot patch:       {q_std:6.1f} phys/logical")
print()
print(f"  >>> Pinnacle's QLDPC memory is {q_cold/pin_mem:.1f}x DENSER than yoked cold storage.")
print(f"  >>> And {q_std/pin_mem:.1f}x denser than a hot surface-code patch.")
print()
print("  So importing the yoked code into Pinnacle's memory would make it")
print(f"  {pin_mem/q_cold:.2f}x WORSE, not better. The fusion is self-defeating.")
print()
print("=== Reverse direction: is Gidney's cold store improvable? ===")
print("  Gidney cold = 1280 logical x 430 = 550,400 phys = 61.30% of 897,864 (VERIFIED).")
print("  Pinnacle at the SAME logical count m=1280, using J254 blocks:")
nblocks = -(-1280//14)   # ceil
tot = nblocks*508
print(f"    ceil(1280/14) = {nblocks} blocks x 508 = {tot:,} physical")
print(f"    vs Gidney's 550,400  -> {100*tot/550400:.1f}%  ({tot-550400:+,} physical)")
print()
print("  => Even the ONE place the yoked code is used (61.3% of Gidney) is")
print("     beaten by simply swapping in a QLDPC memory. The yoked code is")
print("     NOT the density winner; it only wins under a 2D-LOCAL connectivity")
print("     constraint that QLDPC codes violate.")
print()
print("=== Is that a fair comparison? THE COMPARABILITY CAVEAT (load-bearing) ===")
print("  Gidney/yoked: nearest-neighbour 2D grid, p=1e-3, surface code d=25.")
print("  Pinnacle: QLDPC requires NON-nearest-neighbour long-range connections.")
print("  Yoked paper (fetched): 'Our construction assumes no additional")
print("    connectivity beyond a nearest-neighbor square qubit grid'.")
print("  Pinnacle (fetched): 'Since the most widely used QLDPC codes are...")
print("    -> the two are NOT interchangeable on the same hardware.")
print("  This caveat is why the density gap above is NOT a refutation of Gidney.")
print("  It only refutes the SYNTHESIS: you cannot have both properties at once.")
