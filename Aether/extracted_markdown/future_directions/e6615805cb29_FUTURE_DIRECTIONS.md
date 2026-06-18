# Future Directions: Mathematical Foundations of Integrated Information

The file `IntegratedInformation.lean` formalizes the combinatorial skeleton of
Tononi's Integrated Information Theory (IIT): a finite `System` carries an
effective-information functional `ei` over nontrivial bipartitions (`parts`), and
the integrated information `Φ` is the value at the Minimum Information Partition.
We proved that the MIP exists and realizes `Φ` (`exists_MIP`), that `Φ` is the
greatest lower bound of the landscape (`phi_le_ei`, `le_phi`), that `Φ ≥ 0`
(`phi_nonneg`), the reducibility dichotomy `Φ = 0 ↔ ∃` a zero cut
(`phi_eq_zero_iff`), and a monotonicity principle (`phi_mono`). The following
directions extend this scaffold toward the harder claims of IIT.

## 1. Full partition lattice, not just bipartitions

Our `parts n` ranges over bipartitions (a subset and its complement). Real IIT
quotients over the full lattice of set partitions of the elements, and `Φ` is the
infimum of the partition-distance over *all* partitions, normalized by partition
size. Conjecture: defining `partsFull n` as `Finset.univ`-indexed
`Setoid`/partition objects, the bipartition `Φ` is an *upper bound* for the
full-lattice `Φ`, with equality exactly when the minimizing partition is binary.

**The key insight is** that the partition lattice is graded by block count, and
the effective-information functional is supermodular along refinement, so the
minimizer can be searched block-count by block-count rather than over the
super-exponential lattice at once. **Why now?** Mathlib's `Finpartition` API and
its order structure (`Finpartition.instLattice`) are now mature enough to host
`ei : Finpartition (univ : Finset (Fin n)) → ℝ` and the `min'` machinery we
already use transfers verbatim.

## 2. NP-hardness of computing Φ via a Karp reduction to MIN-BISECTION

The concept brief asks to show `Φ` is NP-hard to compute. The honest formal route
is a Karp reduction: encode an instance of weighted graph MIN-BISECTION as an IIT
`System` whose `ei` on a cut `A` equals the cut-weight `w(A, Aᶜ)`, so that the MIP
*is* the minimum bisection and `Φ` *is* its weight. Conjecture: there is a
polynomial-time computable map `g : Graph → System` with
`Φ (g G) = minBisection G`, witnessed inside Mathlib's
`Computability`/`Polynomial`-time reduction framework.

**The key insight is** that `phi_eq_zero_iff` already shows `Φ` decides a
combinatorial existence question ("is there a balanced zero cut?"), which is the
decision-problem shadow of an NP-complete bisection question — so the reduction
target is structurally identical to what we proved. **Why now?** With
`exists_MIP` pinning `Φ` to an explicit argmin, the reduction reduces to proving a
single arithmetic identity `ei A = cutWeight A`, isolating the hardness in a
clean, checkable lemma rather than in the optimization itself.

## 3. A provable polynomial-time approximation with a multiplicative guarantee

Construct a poly-time computable `ΦApprox : System → ℝ` (e.g. the best cut found
by a spectral or greedy heuristic restricted to `parts`) and prove a two-sided
bound `Φ ≤ ΦApprox ≤ c · Φ` for an explicit constant `c`. Our `phi_le_ei` already
gives the trivial direction (`Φ ≤ ei A` for *any* heuristic cut `A`), so only the
upper guarantee needs new work.

**The key insight is** that `le_phi` characterizes `Φ` as a greatest lower bound,
so an approximation guarantee is exactly a *certificate* that a candidate value is
within factor `c` of that bound — turning approximation into a lower-bound proof
obligation we are already equipped to discharge. **Why now?** The
greatest-lower-bound characterization (`le_phi`) means we never have to reason
about the global optimizer's identity, only about inequalities against it, which
is precisely the regime where `linarith`/`gcongr` automation excels.

## 4. Sub/super-additivity of Φ under system composition

Define a tensor/disjoint-union composition `S ⊗ T` on `System m` and `System n`
and study how `Φ (S ⊗ T)` relates to `Φ S` and `Φ T`. Conjecture: for the
disjoint union with no cross-edges, `Φ (S ⊗ T) = 0` (the union is reducible along
the obvious cut), recovering the IIT axiom that genuinely separate systems have no
integrated information.

**The key insight is** that the disjoint-union cut is always a member of
`parts (m+n)` with `ei = 0`, so `phi_eq_zero_iff` immediately forces `Φ = 0`;
non-triviality only appears once cross-edges are added, quantifying integration as
a strictly positive defect. **Why now?** `phi_eq_zero_iff` is already proved, so
the composition theorem is a corollary the moment the union's zero cut is
exhibited — a short, high-confidence next step.

## 5. Uniqueness and stability of the MIP under perturbation

`exists_MIP` gives existence of a minimizer but not uniqueness. Conjecture: if the
effective-information landscape is *strictly* minimized at `A₀` (a gap `δ > 0`
above the runner-up), then every system `T` with `‖T.ei - S.ei‖∞ < δ/2` shares the
same MIP `A₀`, and `|Φ S - Φ T| ≤ ‖S.ei - T.ei‖∞`.

**The key insight is** that `Φ` is a `min'` of finitely many continuous (indeed
1-Lipschitz) coordinate functionals, so it is itself 1-Lipschitz in the sup-norm,
and a spectral gap protects the argmin — a finite-dimensional, fully formalizable
stability statement. **Why now?** Our `phi_mono` already proves monotonicity, the
one-sided half of Lipschitz continuity; promoting it to a two-sided modulus is a
direct strengthening that `phi_eq_of_common_mip` (shared-MIP equality) was
designed to seed.
