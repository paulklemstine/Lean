# Dream Logic: How Contradictions Can Coexist Without Taking Over

A dream can hold two incompatible pictures at once. A familiar room is both childhood home and railway station. A person is absent and standing beside you. The scene does not collapse into total nonsense; instead, the contradiction remains local. Other facts—there is rain at the window, a red suitcase on the floor—retain their own status.

Classical logic treats contradiction very differently. If a theory accepts both a statement $p$ and its negation $\neg p$, then the principle of explosion permits every conclusion $q$. That rule is invaluable when “acceptance” means truth in a consistent mathematical theory. It is less suitable when acceptance means that a database, witness record, evolving model, or human memory currently carries a piece of evidence. Real information systems can contain conflicts without thereby containing everything.

A compact mathematical model captures this dream-like behavior. It also reveals three structures beneath it: a paraconsistent semantics in which contradiction stays local, a non-monotone dynamics in which new evidence can retract old evidence, and a finitary geometry whose admissible regions survive finite unions but not arbitrary ones. A parallel algebraic model explains selective forgetting as quotienting streams of experience.

## Signed information

Let $A$ be any set of atoms: propositions such as “the door is open” or “the train arrived.” A **literal** is a pair $(a,s)$ with $a\in A$ and $s\in\{+,-\}$. The opposite of $(a,+)$ is $(a,-)$, and conversely. A **belief state** $B$ is simply a set of literals. It entails a literal exactly when that literal belongs to $B$.

An atom $a$ is contradictory in $B$ when both $(a,+)$ and $(a,-)$ lie in $B$. This definition allows four statuses for each atom: unsupported, positive only, negative only, or contradictory. The fourth status is not a disaster; it is data.

The first central result is **Contradiction Without Explosion**. If $a$ and $b$ are distinct atoms, then the state

$$
B=\{(a,+),(a,-)\}
$$

is contradictory about $a$ but does not entail $(b,+)$. The proof is almost visual: $B$ contains exactly two literals, both concerning $a$, while $(b,+)$ concerns a different atom. Contradiction has been represented, but no rule manufactures unrelated information.

This tiny model matters because it separates inconsistency from triviality. Conflicting medical reports about one measurement need not license an arbitrary diagnosis. Two sensors disagreeing about one valve need not imply that every alarm is active. A narrative can be impossible in one respect without becoming indiscriminate in all respects.

## Revision as local surgery

Static coexistence is only half the story. Beliefs change. Define revision by a literal $\ell$ as

$$
R_\ell(B)=\{\ell\}\cup\bigl(B\setminus\{\bar\ell\}\bigr),
$$

where $\bar\ell$ denotes the opposite literal. Revision inserts the new literal and removes precisely its contrary. Everything else is untouched.

The **Acceptance-and-Retraction Theorem** says that $R_\ell(B)$ always entails $\ell$ and never entails $\bar\ell$. This follows directly from the construction: the target is inserted, while its opposite is deleted. Revision is therefore a “last write wins” update on one atom.

This operation is genuinely non-monotone. In monotone reasoning, accepted information can only accumulate: one expects $B\subseteq R_\ell(B)$. But if $B=\{\ell,\bar\ell\}$, then revising by $\ell$ removes $\bar\ell$, so $B\nsubseteq R_\ell(B)$. The **Non-Monotonicity Theorem** states exactly this failure. Retraction is not a bug; it is what permits correction.

Order matters as well. Revising first by $\ell$ and then by $\bar\ell$ yields a state containing $\bar\ell$ but not $\ell$. Reversing the order yields one containing $\ell$ but not $\bar\ell$. Thus the **Order-Sensitivity Theorem** states

$$
R_{\bar\ell}(R_\ell(B))\ne R_\ell(R_{\bar\ell}(B)).
$$

The latest sign wins. This is familiar in editable documents, replicated registers, preference changes, and memory reconsolidation: updates at the same location need not commute.

## Consistency as a conflict-free geometry

There is a second way to view the same states. Build a graph whose vertices are literals and whose only attacks connect each literal to its opposite. A set of vertices is **conflict-free** if it contains no attacking pair. Meanwhile, call a belief state **consistent** if no atom appears with both signs.

The **Consistency–Conflict-Freedom Theorem** says these conditions are equivalent. If a state contains both signs of some atom, it contains an attacking pair. Conversely, every attacking pair consists of two opposite signs of one atom and therefore witnesses inconsistency.

This equivalence turns belief states into faces of a combinatorial complex. Each atom contributes a pair of incompatible choices; a consistent state chooses at most one. Revision becomes movement through that geometry.

Even better, revision preserves consistency. Suppose $B$ is consistent. To revise by $\ell$, remove $\bar\ell$ and insert $\ell$. The only literal that could conflict with $\ell$ has already been removed, and all other pairs retain their former consistency. The **Consistency Preservation Theorem** therefore gives

$$
B\text{ consistent}\quad\Longrightarrow\quad R_\ell(B)\text{ consistent}.
$$

The theorem identifies a safe update rule: every step stays inside the conflict-free region.

## A topology with a boundary

Now restrict attention to finite information states. For any space $X$, call a subset **finitarily open** when it is finite. The empty set is finitarily open. Intersections and unions of two finitarily open sets are finitarily open, and, more generally, the union of any finite family of them is finite.

This resembles topology, but only up to a sharp boundary. Ordinary topologies require arbitrary unions of open sets to be open. Finitary openness does not.

The **Arbitrary-Union Obstruction** supplies the cleanest example. Every singleton $\{n\}$ is a finite subset of the natural numbers, but

$$
\bigcup_{n\in\mathbb N}\{n\}=\mathbb N,
$$

and $\mathbb N$ is infinite. Hence the countable union is not finitarily open. These sets form a finite lattice of information fragments, not an ordinary topology on an infinite carrier.

That distinction is conceptually useful. Any finite observation can be combined with finitely many others. Yet an unbounded accumulation of observations may leave the realm of finite cognitive or computational resources. The failure of arbitrary union marks the gap between locally manageable fragments and a completed global state.

Revision respects this resource boundary. If $B$ is finite, then deleting at most one literal and adding one literal leaves a finite set. Combining this with consistency preservation gives the **Revision Bridge Theorem**: if $B$ is finite and consistent, then $R_\ell(B)$ is again finite and conflict-free. One operation simultaneously respects semantics, combinatorial compatibility, and finite information capacity.

## Forgetting entire histories

Belief revision acts on sets, but experiences arrive in order. Let $\Sigma$ be an alphabet of experience symbols. A finite stream is a word in $\Sigma^*$, including the empty word $\varepsilon$, with concatenation as multiplication. A **compositional memory** is a map

$$
M:\Sigma^*\longrightarrow R
$$

into a monoid $R$ such that $M(uv)=M(u)M(v)$ and $M(\varepsilon)=1$. Two streams are observationally indistinguishable when $M(u)=M(v)$.

If $\Sigma$ is nonempty and $R$ is finite, the **Finite-Memory Loss Theorem** says that distinct streams $u\ne v$ must have the same memory value. There are infinitely many words but only finitely many representations, so the pigeonhole principle forces a collision. Finite memory cannot preserve every history.

The streams erased completely, those satisfying $M(u)=1$, have algebraic structure. They include $\varepsilon$, and if $M(u)=M(v)=1$, then $M(uv)=1$. Thus the **Erased-Stream Theorem** says completely forgotten streams form a submonoid.

Most importantly, forgetting is exactly a quotient. Equality of memory values is compatible with concatenation, so one may identify indistinguishable streams. The **Observable-Quotient Theorem** states that the resulting quotient monoid is isomorphic to the image $M(\Sigma^*)$: classes of histories correspond exactly to observable memory states.

Selective forgetting gives a concrete example. Choose which symbols to retain, delete every unretained symbol, and preserve order among the rest. Every deleted symbol maps to the empty word. Moreover, any other compositional summary that already identifies all streams made equal by this deletion factors uniquely through the quotient. Selective forgetting is therefore not an ad hoc eraser; it is the canonical compression compatible with those identifications.

## The larger picture

Dream logic is not a claim that contradictions are secretly true. It is a disciplined account of information that may be partial, conflicting, revised, bounded, and compressed. Contradiction remains local because entailment is membership. Revision is non-monotone because correction removes a contrary sign. Consistency becomes conflict-freedom in a graph of complementary literals. Finite states form a robust finitary geometry, but countable accumulation exposes the boundary of that geometry. Ordered histories, finally, become observable only up to the equivalence imposed by memory.

Together these results suggest a mathematics of limited minds and limited machines. They also offer a design principle: isolate conflicts by coordinate, make correction explicit, expose resource bounds, and describe compression by the distinctions it erases. The same principle can guide a medical record, a sensor network, a redacted event log, or a fictional world whose impossible details remain intelligible.

We do not need every inconsistency to detonate, every update to preserve the past, or every history to remain distinguishable. We need precise rules for what coexists, what is retracted, what remains finite, and what becomes the same after forgetting. That is the sober structure beneath dream logic.