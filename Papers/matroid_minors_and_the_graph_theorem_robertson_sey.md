# Computational evidence

The theorem proved here (`Catalog/Novelty/ExcludedMinors/WellQuasiOrderFiniteBasis.lean`)
is the order-theoretic engine behind two finiteness phenomena:

* **Robertson–Seymour** — a minor-closed family is cut out by *finitely many*
  forbidden minors;
* **Dickson's lemma** — a monomial ideal (upper set of exponent vectors in `ℕ^k`)
  has *finitely many* minimal generators.

Being a universally quantified identity about well-quasi-orders, it is not a
numerical conjecture; the "evidence" is that the finiteness it predicts is
observed in every small instance, and that no counterexample can exist because
the finiteness is forced by antichain-finiteness in a WQO.

## 1. Small cases of the forbidden-family theorem on `ℕ`

For `S ⊆ ℕ` a lower set (initial segment), `exists_finite_forbidden_family`
produces `B = minimal elements of Sᶜ`:

| lower set `S`            | complement `Sᶜ`   | forbidden set `B` | size |
|--------------------------|-------------------|-------------------|------|
| `∅`                      | `ℕ`               | `{0}`             | 1    |
| `{0}`                    | `{1,2,3,...}`     | `{1}`             | 1    |
| `{0,1,...,n-1}`          | `{n,n+1,...}`     | `{n}`             | 1    |
| `ℕ` (all)                | `∅`               | `∅`               | 0    |

Every proper lower set of `ℕ` is `{x | x < n}` and is forbidden by the single
element `n`; the "all" set has empty forbidden family. Finite in every case. ✓

## 2. Small cases of Dickson's lemma on `ℕ^2`

Minimal generators of upper sets `U ⊆ ℕ^2` (monomial ideals):

| upper set `U` (as `x ≥ g` union)        | minimal generators `G`      | size |
|-----------------------------------------|-----------------------------|------|
| `⟨2,0⟩ ≤ x  or  ⟨0,3⟩ ≤ x`              | `{(2,0),(0,3)}`             | 2    |
| `⟨1,1⟩ ≤ x`                             | `{(1,1)}`                   | 1    |
| `⟨3,0⟩,⟨2,1⟩,⟨0,2⟩ ≤ x`                 | `{(3,0),(2,1),(0,2)}`       | 3    |
| `ℕ^2 \ {(0,0)}` (everything but origin) | `{(1,0),(0,1)}`             | 2    |

Each monomial ideal has a finite minimal generating antichain, as Dickson's
lemma guarantees. ✓ (These match the standard "staircase" pictures of monomial
ideals.)

## 3. The mission's excluded-minor count (context)

The mission text lists the ternary (GF(3)) excluded minors as `F_7`, `F_7*`, and
the non-Pappus matroid. The *established* theorem (Bixby; Seymour; Kahn) is that
the excluded minors for GF(3)-representability are exactly the **five** matroids

    U_{2,5},  U_{3,5},  F_7,  F_7*,  P_8 .

The exact list is not what our Lean theorem asserts; what our theorem captures is
the structural reason such a list is **finite at all**: GF(3)-representable
matroids are (conjecturally, and by the Geelen–Gerards–Whittle program) WQO under
minors, and *any* WQO minor order forces every minor-closed class — in particular
the class of representable matroids — to have a finite forbidden-minor set. The
finite cardinality 5 above is one confirmed data point of this finiteness.

## 4. Counterexample hunt

No counterexample is possible: `exists_finite_forbidden_family` and `dickson` are
proved in Lean with only the axioms `propext, Classical.choice, Quot.sound`
(verified by `#print axioms`). The finiteness cannot fail in any WQO because an
antichain in a WQO is finite (`IsAntichain.finite_of_wellQuasiOrdered`), and the
forbidden/generating family is always an antichain
(`isAntichain_minimalGens`).
