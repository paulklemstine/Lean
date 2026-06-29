# Theorem Trace — Homotopy Type Theory Foundations

Internal anti-hallucination ledger. Every name below is taken verbatim from the
Phase A Lean output. No result is stated in `ARTICLE.md` / `RESEARCH_PAPER.md`
that does not appear here.

## FundamentalIdentity.lean (namespace `HoTT`)

| Lean name | Kind | Statement | Article | Paper |
|---|---|---|---|---|
| `IsContr` | structure | `A : Sort u` is contractible: a `center : A` with `contraction : ∀ x, center = x` | §"A point that swallows its space" | Def. 1 |
| `Fiber` | def | `Fiber f y := Σ' x, f x = y` | §"Fibers" | Def. 2 |
| `IsEquiv` | def | `IsEquiv f := ∀ y, IsContr (Fiber f y)` | §"Equivalence as contractible fibers" | Def. 3 |
| `IsContr.subsingleton` | theorem | `IsContr A → ∀ x y : A, x = y` | mentioned | Lemma 1 |
| `singleton_isContr` | def | `IsContr (Σ' y, a = y)` with center `⟨a, rfl⟩` | §"Based path spaces" | Thm. 1 |
| `encode` | def | `encode a B b x : a = x → B x := fun p => p ▸ b` | §"Transport" | Def. 4 |
| `fundamental_identity_forward` | def | `(∀ x, IsEquiv (encode … x)) → IsContr (Σ' x, B x)` | §"Main theorem (forward)" | Thm. 2 (⇒) |
| `fundamental_identity_backward` | def | `IsContr (Σ' x, B x) → ∀ x, IsEquiv (encode … x)` | §"Main theorem (backward)" | Thm. 2 (⇐) |
| `isEquiv_encode_of_isContr` | def | for family `fun x => PLift (a = x)`, `encode` is a fiberwise equivalence | §"Corollary" | Cor. 1 |

## PropTruncation.lean (namespace `HoTT.Trunc`)

| Lean name | Kind | Statement | Article | Paper |
|---|---|---|---|---|
| `Trunc` (`∥A∥`) | def (Quot of total relation) | propositional truncation as `Quot (fun _ _ => True)` | §"Squashing a type" | Def. 5 |
| `mk` | def | point constructor `A → ∥A∥` | §"Squashing a type" | Def. 5 |
| `Trunc.isProp` | theorem | `∀ x y : ∥A∥, x = y` (the path constructor) | §"A mere proposition" | Thm. 3 |
| `Trunc.lift` / `Trunc.lift_mk` | def / theorem | recursor into props with `lift f (mk a) = f a` | §"Universal property" | Thm. 4 |
| `Trunc.ind` | theorem | dependent eliminator into proposition families | §"Universal property" | Thm. 4 |
| `Trunc.equivOfIsProp` | def | for a proposition `A`, `mk : A → ∥A∥` is an equivalence | §"Idempotence" | Thm. 5 |
| `Trunc.prod_equiv` | def | `∥A × B∥ ↔ ∥A∥ × ∥B∥` | §"Truncation respects products" | Thm. 6 |

## Univalence.lean (namespace `HoTT`, per future-directions notes)

| Lean name | Kind | Statement | Article | Paper |
|---|---|---|---|---|
| `UnivalenceData` | structure | bundled `idToEquiv` together with an inverse witness | §"Univalence" | Def. 6 |
| `idToEquiv` | def | `A = B → (A ≃ B)` (transport of identities to equivalences) | §"Univalence" | Def. 6 |
| `negEquiv` | def | the equivalence `Bool ≃ Bool` given by `not` | §"The Bool obstruction" | Def. 7 |
| `UnivalenceData.not_inhabited` | theorem | `UnivalenceData → False` (univalence is inconsistent with `Eq : Prop`) | §"Why it must fail" | Thm. 7 |
| `propUnivalence` | def/theorem | on `Prop`, `(P = Q) ≃ (P ≃ Q)` via `propext` | §"Univalence survives on propositions" | Thm. 8 |
| `propUnivalence_idToEquiv` | theorem | `idToEquiv` realizes that equivalence on `Prop` | §"Univalence survives on propositions" | Thm. 8 |
