# E-6 Survey: Smoothness-Lottery Structures Beyond Elliptic Curves

The FACT barriers prove invariants-of-N dead; surviving methods are smoothness
lotteries over random algebraic structures. ECM's lottery: elliptic-curve group
orders ~ p·(1±p^{-1/2}) — random enough that some curve is B-smooth.

## Candidates
1. **Quadratic-field class groups** (Cl(Q(√d)), d random): orders ~ √d · L-distributed
   (Cohen-Lenstra heuristics favor odd parts). Action on ideals could replace curve
   points. Obstruction: no fast CM-style construction of d with target-smooth Cl.
   STATUS: unexplored empirically; testable via h(d) computation for small d.
2. **Genus-2 Jacobians** (Hyperelliptic-ECM): order ~ q²; CM construction exists
   (Spallek/van Wamelen) but expensive ~10x per curve. Lottery quality similar to
   EC (Hasse interval relatively narrower). Prior work: lukewarm results.
3. **Unit groups of random number fields** (φ-analogue): orders factor unpredictably;
   no efficient group-action construction known. BLOCKED at construction.
4. **Drinfeld modules** (function-field analogue of ECM): theoretically parallel to
   EC over function fields; integer-correspondence unclear. OPEN theory.

## Verdict & E-6 testable design
Class groups (1) are the only candidate both unexplored and constructible:
Experiment design — compute Cl(Q(√(-d))) for 10^4 random d ≈ p, measure smoothness
distribution of |Cl| vs elliptic-order baseline at matched size. If P_B-superior:
prototype ideal-ECM. Runtime ~hours (PARI).
