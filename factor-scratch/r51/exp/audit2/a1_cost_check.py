#!/usr/bin/env python3
"""A1 FINAL: is the 25-38% traceable, and is it the paper's own number or inherited?

Source: factor-scratch/r48/notes/C_smoothness.md:338 --
  'At the NFS operating point u ~= 3 the naive reading is a ~25-38% reduction in
   collection cost.'
The word is NAIVE.  The paper #523 s6 quotes it as:
  'Measured end-to-end by the round-48 smoothness axis, the effect is a 25-38%
   reduction in relation-collection cost at the operating point u~=3.'
=> 'naive reading' became 'Measured end-to-end'.  Trace the delta table it comes from.
"""
print("=== A1.5  WHERE 25-38% COMES FROM: C_smoothness.md delta table ===")
print("delta(u) size-matched, from notes/C_smoothness.md s3:")
delta={1.6:1.0509,2.0:1.1010,2.4:1.1674,2.8:1.2461,3.2:1.3776,3.6:1.5437,4.0:1.7254}
print(f"{'u':>5} {'delta':>8} {'cost_red = 1-1/delta':>21}")
for u,d in delta.items():
    print(f"{u:>5} {d:>8.4f} {(1-1/d)*100:>20.1f}%")
print()
print("  u=2.8 -> 19.7% ; u=3.2 -> 27.4% ; u=3.6 -> 35.2%")
print("  The '25-38%' band corresponds to u ~ 3.1 - 3.8, i.e. it is an INTERPOLATION")
print("  of a table measured only at u <= 4, N ~ 1e8.  C_smoothness.md s4 says so:")
print("    'delta(u) was never measured at u > 4, and NFS's operating point is u ~= 3-5.'")
print()
print("=== A1.6  TWO SEPARATE PROBLEMS WITH THE PAYOFF ===")
print("  (a) The source calls it 'the naive reading'.  #523 upgrades it to")
print("      'Measured end-to-end'.  That is a provenance upgrade of a hedged")
print("      number into a stated measurement.")
print("  (b) A 25-38% reduction in COLLECTION cost does NOT follow from delta at all.")
print("      delta is a ratio of SMOOTH-VALUE YIELDS.  Collection cost is inversely")
print("      proportional to yield ONLY if everything else is unchanged.  C_smoothness.md")
print("      s3 measures that it is NOT: restricting to any sub-box has net gain < 1")
print("      (a,b both even -> 0.2455; both mult of 3 -> 0.1098; a odd -> 0.4908).")
print("      The k>=2 excess lives ENTIRELY in the zero-subspace, which is a sub-box,")
print("      so the excess is exactly the thing the note says cannot be cashed.")
