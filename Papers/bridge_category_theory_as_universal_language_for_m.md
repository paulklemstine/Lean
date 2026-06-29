# Theorem Trace (internal anti-hallucination ledger)

Every name below appears verbatim in the Phase A Lean file
`Catalog/Bridges/ToposDoubleNegationLattice.lean` (namespace
`ToposDoubleNegationLattice`), or in its imported dependency
`Catalog/Bridges/KnasterTarskiBridge.lean` (namespace `KnasterTarskiBridge`).
No theorem is stated in the prose that is not on this list.

Ambient setting: `{α : Type u} [Order.Frame α]` (a complete Heyting algebra /
frame). Operations: meet `⊓`, join `⊔`, Heyting implication `⇨`, pseudocomplement
`aᶜ := a ⇨ ⊥`, bounds `⊤`, `⊥`.

| Lean name | Kind | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|---|
| `himp_isGreatest` | theorem | `a ⇨ c` is the greatest `x` with `a ⊓ x ≤ c`; i.e. `IsGreatest {x | a ⊓ x ≤ c} (a ⇨ c)`. Conjunction `(a ⊓ ·)` is left adjoint to implication `(a ⇨ ·)`. | §"The universal property" | Thm 1 (Universal property of implication) |
| `dneg` | def | `dneg a := aᶜᶜ` (double pseudocomplement). | §"Double negation" | Def 2 |
| `le_dneg` | theorem | `a ≤ dneg a` (extensive). | §"Double negation" | Thm 3(i) |
| `dneg_monotone` | theorem | `Monotone dneg`. | §"Double negation" | Thm 3(ii) |
| `dneg_idem` | theorem | `dneg (dneg a) = dneg a` (idempotent), from triple-negation `aᶜᶜᶜ = aᶜ`. | §"Double negation" | Thm 3(iii) |
| `dneg_inf` | theorem | `dneg (a ⊓ b) = dneg a ⊓ dneg b` (meet-preserving). | §"Double negation" | Thm 3(iv) |
| `dneg_bot` | theorem | `dneg ⊥ = ⊥`. | §"Regular elements" | Thm 3(v) |
| `dneg_top` | theorem | `dneg ⊤ = ⊤`. | §"Regular elements" | Thm 3(v) |
| `IsRegular` | def | `IsRegular a := dneg a = a`. | §"Regular elements" | Def 4 |
| `isRegular_bot` | theorem | `IsRegular ⊥`. | §"Regular elements" | Cor 5 |
| `isRegular_top` | theorem | `IsRegular ⊤`. | §"Regular elements" | Cor 5 |
| `isRegular_inf` | theorem | `IsRegular a → IsRegular b → IsRegular (a ⊓ b)`. | §"Regular elements" | Thm 6 |
| `isRegular_iff` | theorem | `IsRegular a ↔ dneg a ≤ a`. | §"Regular elements" | Lem 7 |
| `lfp_dneg_eq_bot` | theorem | `sInf (preFixed dneg) = ⊥`. | §"Fixed points" | Thm 8(i) |
| `gfp_dneg_eq_top` | theorem | `sSup (postFixed dneg) = ⊤`. | §"Fixed points" | Thm 8(ii) |
| `dneg_knaster_tarski` | theorem | `dneg (sInf (preFixed dneg)) = sInf (preFixed dneg)`. | §"Fixed points" | Cor 9 |
| `KnasterTarskiBridge.knaster_tarski` | theorem (dep) | For monotone `f` on a complete lattice, `f (sInf (preFixed f)) = sInf (preFixed f)`. | §"Fixed points" | Thm 0 (background) |
| `KnasterTarskiBridge.preFixed` | def (dep) | `preFixed f := {x | f x ≤ x}`. | §"Fixed points" | Def (background) |
| `KnasterTarskiBridge.postFixed` | def (dep) | `postFixed f := {x | x ≤ f x}`. | §"Fixed points" | Def (background) |

Refined-claim note (must appear in prose, not as a theorem): the literal slogan
"every Grothendieck topos is a bounded lattice" is a category error; the true
statement is about the *subobject lattice* of a fixed object, modeled by
`Order.Frame α`. `TopologicalSpace.Opens X` is the topological instance.
