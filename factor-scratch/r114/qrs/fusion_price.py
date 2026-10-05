#!/usr/bin/env python3
"""Price the ONE fusion candidate not in the ledger: put the INPUT REGISTER in yoked
HOT storage (accessible, ~2x density) instead of cold storage, so loop1 never has to
stream out of cold. All densities are FETCHED (see quotes in RESULT.md)."""
q_std   = 1352   # Gidney p18: 2*(25+1)^2, verbatim
q_cold  = 430    # Gidney p18: "yoking with a 2D parity check code reaches ... 430 physical qubits"
# Yoked paper Discussion (fetched): yoked HOT storage = "nearly twice as many logical
# qubits per physical qubit as standard surface codes" -> density factor ~2.
# We bracket it: 2x (optimistic, the paper's own word "nearly twice") .. 3x (cold's factor)
m = 1280
print("=== A. Is the input register already at its cheapest code? ===")
for fac,lbl in [(3.0,'yoked COLD (2D, Gidney p18)'),(2.0,'yoked HOT (Discussion, "nearly twice")')]:
    dens = q_std/fac
    tot  = m*dens
    print(f"  {lbl:38s} {dens:7.1f} phys/logical x {m} = {tot:9,.0f} physical")
print(f"  Gidney actual cold spend                        430.0 phys/logical x {m} = {m*q_cold:9,.0f} physical")
print()
dens_hot = q_std/2
delta = m*dens_hot - m*q_cold
print(f"=== B. Moving the input register cold -> yoked-HOT ===")
print(f"  cost change: {delta:+,.0f} physical qubits ({delta/(m*q_cold)*100:+.1f}%)")
print(f"  total footprint 897,864 -> {897864+delta:,.0f}")
print("  => yoked-HOT is MORE expensive in SPACE. It buys ACCESS, not density.")
print("     The fusion is only worth it if the loop1 streaming contention is fatal.")
print()
print("=== C. The access price, in TIME (yoked Fig.5, fetched) ===")
d = 25
for nb in [8,16,32,64]:
    cyc = 8*d*nb + 2*d
    print(f"  1D yoked, {nb:2d} blocks: syndrome cycle = 8*{d}*{nb} + 2*{d} = {cyc:5d} rounds"
          f"  (vs {d} for a bare patch -> {cyc/d:.0f}x)")
print("  2D yoked: 25*d*w + 4*d with w=8 ->", 25*d*8+4*d, "rounds")
print("  => a yoked logical qubit cannot be cycled at anything like surface-code rate.")
print("     Using yoked-HOT for a register that is operated on CONTINUOUSLY is a T-count")
print("     disaster: the memory layer costs ~100-500x per round.")
print()
print("=== D. rho-parallelisation: what it actually multiplies ===")
print("  Pinnacle Eq.22: N = m + rho*Nw.  m is SHARED. rho multiplies Nw (working regs).")
print("  A working register is hot by construction. Yoked contributes 0 of it.")
kappa = 33+2*21+4+2*max(33,21+4)+1
print(f"  Pinnacle Eq.23 kappa = {kappa} logical/working-register")
print(f"  Gidney-domain marginal cost per extra register = {kappa} x {q_std} = {kappa*q_std:,} physical")
for rho in [1,8,16,32]:
    tot = m*q_cold + 131*q_std + 170352 + (rho-1)*kappa*q_std
    print(f"    rho={rho:2d}: naive Gidney+rho = {tot:11,.0f}  ({tot/897864:5.2f}x baseline)")
print("  At rho=32 the cold fraction has COLLAPSED -- the parallelism ate the cold store,")
print("  which is the opposite of the hypothesised fusion.")
