# Future Directions: Infinite Games Against Death

## 1. Transfinite Game Length and Ordinal Survival

The current framework proves that Mortal can survive any finite number of rounds (i.e., ω rounds total) via the Safe Move Survival Theorem. The natural extension is to formalize games indexed by ordinals rather than natural numbers, where Mortal's goal is to survive transfinitely many rounds. The conjecture is: **if Mortal has bounded nondeterminism (at most k choices per round) and Eternity's responses are also bounded, then Mortal can force survival for ω·k rounds by playing in k "epochs," each of length ω, using a different diagonalization strategy per epoch.**

The key insight is that bounded nondeterminism transforms the strategy space from uncountable to countable, enabling a stage-by-stage diagonalization where each epoch neutralizes one class of Eternity strategies. Why now? Our `Survives` inductive type and `safe_move_survival_from` theorem provide the infrastructure for composing survival guarantees across independent game segments — extending the indexing from ℕ to ordinals requires only replacing the induction principle while preserving the compositional structure.

## 2. Borel Determinacy for Infinite Game Trees

Our Zermelo determinacy result (`GTree.determinacy`) handles finite trees. Martin's theorem (1975) extends this to Borel-measurable payoff sets on infinite game trees. The conjecture to formalize: **for a game on ℕ^ω with a clopen winning condition (equivalently, a condition depending on only finitely many coordinates), determinacy holds constructively — one player has a winning strategy computable from the clopen data.**

The key insight is that clopen determinacy is equivalent to well-founded induction on the rank of the clopen set, which is exactly the pattern our `GTree.determinacy` proof uses — the finite tree structure encodes the finite dependency. Why now? Mathlib's `Topology.Basic` and ordinal arithmetic provide the ambient framework, and our `MortalWins`/`EternityWins` inductive definitions can be lifted to infinite trees with well-founded payoff ranks without fundamental redesign.

## 3. Connection to Infinite Time Turing Machines

Hamkins and Lewis introduced Infinite Time Turing Machines (ITTMs), which compute through transfinite time. The conjecture is: **the set of positions where Mortal has a winning strategy in a computable game (where transitions are ITTM-computable) is Σ₁¹-complete, strictly harder than the corresponding set for finite-time computable games.** Equivalently, ITTM-computable games exhibit a complexity jump exactly analogous to the jump from decidable to Σ₁⁰ in classical computability.

The key insight is that an ITTM can simulate all finite strategies of Mortal in ω steps, then use the limit rule to extract a winning strategy if one exists — but the question of whether this extraction succeeds is itself a Π₁¹ question about well-foundedness of the game tree. Why now? Our framework cleanly separates the game structure (GTree, Survives) from the computational model, allowing the ITTM connection to be formalized as a computability-theoretic property of the `mortalWins` predicate rather than requiring a ground-up redesign.

## 4. Quantitative Survival: Game Entropy and Strategy Complexity

Beyond the qualitative question "can Mortal survive?", there is a quantitative theory of how efficiently Mortal can survive. Define the **strategy entropy** of a game as the infimum of Shannon entropy over Mortal's optimal mixed strategies. The conjecture: **for games where Mortal has m moves and Eternity has e moves per round, the strategy entropy is exactly log₂(m) - log₂(e) when m > e, and the game is losing for Mortal when m ≤ e.**

The key insight is that this connects game-theoretic survival to information-theoretic capacity — Mortal's advantage is precisely the rate at which Mortal can "outrun" Eternity's information about Mortal's strategy. Why now? Our `Survives` predicate already captures the existential-universal alternation that underlies this entropy calculation, and Mathlib's `MeasureTheory.Measure.MeasureSpace` provides the measure-theoretic foundations for formalizing mixed strategies.

## 5. Multi-Player Immortality Coalitions

Extend the two-player framework to k Mortals cooperating against Eternity. The conjecture: **k cooperating Mortals, each with m moves, can survive against an Eternity with e moves if and only if m^k > e, and moreover the optimal coalition strategy decomposes as a product of independent single-player strategies when the game has a product structure.**

The key insight is that coalition survival reduces to a tensor product of individual survival games when the loss condition factors, but entangled loss conditions (where one Mortal's loss depends on another's history) can create strictly harder games requiring genuine coordination. Why now? Our `GTree` framework naturally extends to multi-player games by adding player labels to internal nodes, and the `AllMortalWins`/`AllEternityWins` list predicates generalize to predicates over player-indexed families.
