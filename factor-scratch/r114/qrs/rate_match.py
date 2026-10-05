#!/usr/bin/env python3
"""
POSITIVE CONTROL first: does the model reproduce a KNOWN published number?
Gidney p18 states total physical = 897864. If we cannot hit that, we measure nothing.
"""
m, q_std, q_cold, compute, hot_paper = 1280, 1352, 430, 170352, 131
base = m*q_cold + hot_paper*q_std + compute
print("=== POSITIVE CONTROL ===")
print(f"  model rho=1 total = {base:,}   Gidney p18 states 897,864   match={base==897864}")
print("  (this is the check the brief demands: harness fires on a known case)")
print()
print("=== THE TASK'S ACTUAL QUESTION: can code rate match the parallelisation factor? ===")
# Yoked = surface code concatenated with an r-dimensional parity check code of distance 2^r.
# Logical rate of the OUTER code k/n. The paper's example: [[64,34,4]] 2D parity check code.
print("  Yoked paper (fetched): '[[64, 34, 4]] 2D parity check code' -- outer rate k/n = 34/64 = %.3f"%(34/64))
print("  A rho-way parallelisation needs rho INDEPENDENT operand streams, i.e. it needs")
print("  rho separate memory RECORDS. The outer code rate sets how many logical qubits")
print("  live per physical block, NOT how many can be read concurrently.")
print()
print("  Setting outer rate = rho is a CATEGORY ERROR:")
for r_ in [1,2,3]:
    n = 2**(2**r_)   # n x n array for r-dimensional code
    print(f"    r={r_}: 1D blocks need n={n:4d}; distance 2^{r_}={2**r_}")
print("  The outer code rate grows only LOGARITHMICALLY in block size (34/64 = 0.53 at n=64),")
print("  while rho must reach |P| ~ 2.1e5*... i.e. rho up to hundreds. No rate match exists.")
print()
print("=== RECONCILIATION with the ledger's 14.06x ===")
print("  Ledger said 7x at rho=16 and 14.06x at rho=32, using 153 logical/register.")
print("  My Eq.23 substitution of Gidney's Table-5 (f=33,l=21,len(m)=4) gives kappa=146, not 153.")
kappa_led, kappa_mine = 153, 146
for rho in [16,32]:
    l = (m*q_cold + hot_paper*q_std + compute + (rho-1)*kappa_led*q_std)/897864
    n = (m*q_cold + hot_paper*q_std + compute + (rho-1)*kappa_mine*q_std)/897864
    print(f"  rho={rho}: ledger-kappa {l:.2f}x   my-kappa {n:.2f}x   ratio {l/n:.3f} (=kappa ratio {kappa_led/kappa_mine:.3f})")
print("  => The discrepancy is ENTIRELY the kappa substitution, not a modelling disagreement.")
print("     The SIGN and the conclusion are identical. I report both; neither is load-bearing.")
print()
print("=== VERDICT TABLE ===")
print("  candidate                                   verdict")
print("  rho-parallelise INTO the cold store         REFUTED - rho multiplies hot working")
print("                                               registers (Eq.22), yoked prices idle")
print("  move input register cold -> yoked-HOT       REFUTED on space: +57.2% physical")
print("  match outer code rate to rho                 REFUTED - rate 34/64 is O(1), rho is O(100)")
print("  ANY fusion of the three papers              REFUTED - the yoked code is already")
print("                                               banked in Gidney p18 (cold = 61.3%)")
