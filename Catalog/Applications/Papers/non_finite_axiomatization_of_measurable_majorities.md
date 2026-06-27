# Computational Evidence — Incoherence Index & Non-Finite-Axiomatization

Model (from the catalog `IncoherenceIndex.lean`): a *standard social decision
frame* is a finite atom set `F ⊆ ZMod n`; a *perfectly balanced sequence* is a
non-empty list of atoms of `F` summing to `0`; the *incoherence index* is the
length of the shortest such sequence.

## 1. Small-case calculations: index of the single-generator frame `{1} ⊆ ZMod n`

A balanced sequence of `{1}` is `1` repeated `m` times with `m·1 ≡ 0 (mod n)`,
i.e. `n ∣ m`, `m ≥ 1`.  The shortest is `m = n`.

| n  | frame      | shortest balanced sequence | incoherence index |
|----|------------|----------------------------|-------------------|
| 2  | {1}⊆ZMod 2 | [1,1]                      | 2                 |
| 3  | {1}⊆ZMod 3 | [1,1,1]                    | 3                 |
| 4  | {1}⊆ZMod 4 | [1,1,1,1]                  | 4                 |
| 5  | {1}⊆ZMod 5 | [1,1,1,1,1]                | 5                 |
| 6  | {1}⊆ZMod 6 | 1×6                        | 6                 |

So `incoherenceIndex ({1} ⊆ ZMod n) = n` (additive order of the unit).  This is
the catalog lemma `incoherenceIndex_singleton_one` and underlies every theorem
here.

## 2. The realized lengths `2k+2`

Setting `n = 2k+2` gives the family of *even* indices `≥ 4`:

| k | n = 2k+2 | shortest violation length |
|---|----------|---------------------------|
| 1 | 4        | 4                         |
| 2 | 6        | 6                         |
| 3 | 8        | 8                         |
| 4 | 10       | 10                        |

(`realization_2k2`: every `2k+2` is the index of a *maximal* frame.)

## 3. Counterexample hunt for non-finite-axiomatization

Claim tested: "some fixed bound `B` makes the width-`B` fragment equivalent to
full coherence."  For each candidate `B`, the frame `{1} ⊆ ZMod (B+1)` is a
counterexample — it is maximal, its index is `B+1 > B` (so it passes the
width-`B` test, no violation of length `≤ B`), yet it *is* incoherent
(violation `1` repeated `B+1` times).

| B | counterexample frame | passes width-B? | incoherent? |
|---|----------------------|-----------------|-------------|
| 0 | {1}⊆ZMod 1           | yes             | yes         |
| 1 | {1}⊆ZMod 2           | yes             | yes         |
| 2 | {1}⊆ZMod 3           | yes             | yes         |
| 5 | {1}⊆ZMod 6           | yes             | yes         |

No bound `B` survives.  Formalized as `coherence_not_finitely_axiomatizable`.

## 4. Fragment stratification

`coherentUpTo_iff_lt_incoherenceIndex`: for an incoherent frame, the width-`B`
fragment is passed *iff* `B < incoherenceIndex F`.  Hence the frame `{1} ⊆
ZMod (B+1)` separates width `B` from width `B+1` for every `B`
(`fragment_strictly_refines`): the fragment hierarchy strictly refines forever.

## OEIS note

The index spectrum over single-generator frames is `{n : n ≥ 1}` (all positive
integers, A000027); the *even realized tail* is `4, 6, 8, 10, …` (A005843
restricted to `≥ 4`).  No nontrivial sequence search was required.

All numerical claims above are discharged by the machine-checked theorems in
`NonFiniteAxiomatization.lean` and `IncoherenceStratification.lean` (0 sorries,
axioms: `propext`, `Classical.choice`, `Quot.sound`).
