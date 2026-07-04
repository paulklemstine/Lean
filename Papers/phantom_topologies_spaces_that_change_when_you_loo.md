# Computational Evidence: Phantom Number of the Cofinite / Zariski Line

This note records the small-case checks done before formalizing the claim that the
cofinite (Zariski affine-line) topology has phantom number exactly 2.

## 1. The split observers on a finite model

To gain intuition, model "cofinite-within-S" on a small finite set (where cofinite = full
power set, but the *within-S* refinement structure is still visible for the shape of the
argument). Take X = {0,1,2,3} and S = {0,1}, so Sᶜ = {2,3}.

- Opens of `cofiniteWithin S` (schematically, keeping the "⊆ S with small complement in S"
  branch): all cofinite sets, plus subsets of {0,1}.
- Opens of `cofiniteWithin Sᶜ`: all cofinite sets, plus subsets of {2,3}.
- Common opens: a set that is a subset of {0,1} AND a subset of {2,3} must be ∅; otherwise
  it must be cofinite. So the agreed opens are exactly {∅ and cofinite sets} = the cofinite
  topology. ✔ matches `cofinite_split`.

## 2. The disjointness mechanism (the heart of the split)

The consensus computation reduces to a one-line set fact:

  if U ⊆ S and U ⊆ Sᶜ then U ⊆ S ∩ Sᶜ = ∅.

Checked directly: a "phantom" open of the first observer lives in S, a phantom open of the
second lives in Sᶜ, so a set phantom to both is empty. This is why exactly two observers
suffice, and it is exactly the load-bearing step of the formal proof.

## 3. Strictness of each observer

For the split to be *genuine* each observer must be strictly finer than the cofinite
topology. Witness: S itself is open in `cofiniteWithin S` (S ⊆ S and S \ S = ∅ is finite),
but S is not cofinite when S is infinite and co-infinite (Sᶜ is infinite). On ℝ with
S = (-∞, 0], the set S is a phantom open the cofinite line does not see. ✔ matches
`cofiniteWithin_lt`.

## 4. Non-Hausdorffness on an infinite carrier

Sample check on any infinite X: for nonempty opens u, v (necessarily cofinite), the
complement uᶜ ∪ vᶜ is finite, so u ∩ v is cofinite hence nonempty. Two distinct points can
never be separated, so the space is not Hausdorff and therefore not metrizable — yet it is
T₁ (every singleton has cofinite, hence open, complement). ✔ matches `cofinite_not_t2`,
`cofinite_not_metrizable`, `cofinite_t1`.

## 5. Zariski vs. Euclidean on ℝ

The interval (0,1) is Euclidean-open but not cofinite-open (its complement contains [1, ∞),
which is infinite). Conversely every cofinite set is Euclidean-open (its complement is
finite, hence closed). So the Euclidean line is strictly finer than the Zariski line, giving
two *distinct* realities on ℝ, each with phantom number two. ✔ matches
`euclidean_lt_zariskiLine`, `zariskiLine_ne_euclidean`.

## Sequence/OEIS note

No integer sequence arises: the phantom number is the constant 2 across all infinite
carriers and all infinite/co-infinite splitters, which is itself the headline finding (the
conjectured growth to "≥ 3" does not occur). Counterexample hunt for a reality needing
three observers turned up none, consistent with the catalog's lattice collapse principle.
