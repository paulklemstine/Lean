# Gluing Graphs Along a Clique — A Guided Tour

*What survives when you weld two networks together at a shared clique, what breaks, and exactly why.*

---

## 1. The dream: divide, conquer, reassemble

Someone hands you a complicated network and tells you a comforting secret: it is really **two** smaller networks welded together along a small shared piece. Can you understand the whole thing by understanding the pieces?

That is the oldest ambition in combinatorics, and the most important version of it welds along a **clique** — a set of vertices in which every pair is joined by an edge. This operation is called a **clique sum**, and it is everywhere: [chordal graphs](https://en.wikipedia.org/wiki/Chordal_graph) are exactly what you get by repeatedly clique-summing complete graphs; a [tree decomposition](https://en.wikipedia.org/wiki/Tree_decomposition) is a recipe for assembling a graph by clique sums along small separators; the [graph minor structure theorem](https://en.wikipedia.org/wiki/Graph_structure_theorem) describes whole families of graphs this way.

The question this page answers is: **which graph invariants can be computed from the pieces?** We will settle it for the three classics — the independence number $\alpha$, the clique number $\omega$, and the chromatic number $\chi$ — and, more interestingly, find exactly where the plausible-looking answers are wrong.

<details>
<summary><b>Refresher: the three invariants (click to expand)</b></summary>

- An **independent set** is a set of vertices no two of which are joined by an edge. The **independence number** $\alpha(G)$ is the size of the largest one. (Think: the largest group of mutually non-conflicting tasks.)
- A **clique** is a set of vertices every two of which *are* joined. The **clique number** $\omega(G)$ is the size of the largest one.
- A **proper colouring** assigns colours to vertices so that adjacent vertices differ; the **chromatic number** $\chi(G)$ is the fewest colours needed. Always $\chi(G) \ge \omega(G)$, since a clique needs one colour per vertex.

</details>

---

## 2. The setup, made precise

Fix a finite vertex set $V$. A graph $G$ is a **clique sum** of $G_1$ and $G_2$ along the clique $K$ if there are two *sides* $s, t \subseteq V$ with

- $s \cup t = V$ and $s \cap t = K$ (the sides cover everything and overlap exactly in the weld);
- every edge of $G_1$ lies inside $s$, every edge of $G_2$ lies inside $t$;
- $G = G_1 \cup G_2$;
- **and $K$ is a clique in $G_1$ *and* a clique in $G_2$.**

Write $k = |K|$. That last bullet does all the work. If you only require $K$ to be a clique of the *combined* graph $G$ — allowing its edges to be shared out between the sides so that neither side sees the whole thing — you get what we will call a **weak clique sum**, and, as Section 7 shows, everything on this page fails for it.

---

## 3. Play with it first

Before any theorem, get your hands on the object. In the laboratory below you can set the weld size, hand each side some private vertices, click pairs of vertices to toggle edges, and watch all three invariants and every composition law update live. Load **Witness A** and look at the two highlighted independent sets: each side has an optimal one, and they want *different* vertices of the weld.

{{interactive_demo:0}}

> **Try this.** With Witness A loaded, note $\alpha_1 = 2$, $\alpha_2 = 2$, but $\alpha(G) = 2$: the two sides' witnesses cannot both be used. Then switch the preset to **Witness B** and watch the colouring law and the clique law both turn red.

---

## 4. The humblest fact in the subject

Everything below rests on one line.

> **Lemma (One-Point Trace).** If $A$ is independent and $K$ is a clique, then $|A \cap K| \le 1$.

*Proof.* Two distinct vertices in $A \cap K$ would be adjacent (because $K$ is a clique) and non-adjacent (because $A$ is independent). $\blacksquare$

We call $A \cap K$ the **trace** of $A$ on the weld. The lemma says the trace is empty or a single vertex: **one bit and one address**. That tiny quantity is exactly what the two halves of a clique sum must tell each other — and nothing more.

---

## 5. A beautiful argument that is wrong

Here is the folklore reasoning. Take a maximum independent set $A_1$ on the left and $A_2$ on the right. Each meets $K$ at most once, so their union double-counts at most one vertex, hence
$$\alpha(G) \ \ge\ \alpha_1 + \alpha_2 - 1.$$

Read it again slowly. The error is that $A_1 \cap K$ and $A_2 \cap K$ may be *different* singletons — and then $A_1 \cup A_2$ contains two **adjacent** weld vertices and is not independent at all.

The smallest counterexample is the path on four vertices, drawn below in full.

{{visualization:0}}

<details>
<summary><b>The counterexample, spelled out</b></summary>

Take $V = \{0,1,2,3\}$, $s = \{0,1,2\}$ with $G_1$ the path $2-1-0$, and $t = \{0,1,3\}$ with $G_2$ the path $1-0-3$. The weld is $K = \{0,1\}$, which is genuinely an edge — a $2$-clique — in *both* sides, so this is a legitimate clique sum. Their union is the path $2-1-0-3$.

Now count: $\alpha_1 = 2$ via $\{0,2\}$; $\alpha_2 = 2$ via $\{1,3\}$; but $\alpha(G) = 2$, since a path on four vertices has no three pairwise non-adjacent vertices. Hence
$$\alpha_1 + \alpha_2 = 4 \quad\text{while}\quad \alpha(G) + 1 = 3 .$$
The left witness uses weld vertex $0$; the right one uses weld vertex $1$. Each is optimal alone; together they are illegal.

</details>

---

## 6. The correct laws

### 6a. The sharp uniform bound

> **Theorem.** For every clique sum along a clique of size $k$,
> $$\alpha_1 + \alpha_2 \ \le\ \alpha(G) + \min(k, 2),$$
> and each of the three regimes $k = 0$, $k = 1$, $k \ge 2$ is attained.

<details>
<summary><b>Click to reveal the two-line proof</b></summary>

Take maximum witnesses $A_1, A_2$ and simply *delete the weld from both*: the set $(A_1 \setminus K) \cup (A_2 \setminus K)$ is independent in $G$ (every edge of $G$ lies inside one side, where the relevant vertices form a subset of an independent set), and the two pieces are disjoint (a common element would lie in $s \cap t = K$ and was deleted). Each deletion cost at most one vertex, by the One-Point Trace lemma. So $\alpha(G) \ge \alpha_1 + \alpha_2 - 2$.

When $k \le 1$ the two traces cannot disagree — with at most one candidate vertex, either they are equal (glue directly, losing only the one shared vertex) or one is empty (glue that side with the other side's trace deleted) — giving the $-1$ bound. When $k = 0$ nothing is shared and the independence numbers simply add.

</details>

The experiment below samples random clique sums and plots the observed gap $\alpha_1 + \alpha_2 - \alpha(G)$ against the ceiling $\min(k,2)$ — on the left for genuine clique sums, on the right for weak ones.

{{visualization:1}}

### 6b. The exact answer

Losing a unit is unsatisfying. Ask each side a sharper question and the loss disappears. For $T \subseteq K$, let $\alpha_i(T)$ be the size of the largest independent set of side $i$ whose trace is *exactly* $T$. Only $|T| \le 1$ is realisable, so there are at most $k+1$ questions to ask.

> **Theorem (Trace Decomposition).**
> $$\alpha(G) \;=\; \max_{\substack{T \subseteq K \\ |T| \le 1}} \big(\alpha_1(T) + \alpha_2(T) - |T|\big).$$

<details>
<summary><b>Click to reveal the proof</b></summary>

($\le$) Let $A$ be a maximum independent set of $G$ and $T = A \cap K$, which has size at most one. Its halves $A \cap s$ and $A \cap t$ are independent on their sides, both have trace $T$, their union is $A$ and their intersection is $T$; inclusion–exclusion gives $|A| = |A\cap s| + |A\cap t| - |T| \le \alpha_1(T) + \alpha_2(T) - |T|$.

($\ge$) Fix an admissible $T$ and take optimal traced witnesses on the two sides. Because their traces *agree*, their union is independent — this is the gluing step the folklore argument lacked — and their intersection is exactly $T$, so inclusion–exclusion gives the size. $\blacksquare$

</details>

This is also an algorithm, and a good one: solve $k+1$ constrained problems per side instead of one global problem.

{{algorithm:0}}

### 6c. Colours and cliques compose perfectly

> **Theorem.** Every clique of a clique sum lies entirely inside one side; consequently $\omega(G) = \max(\omega_1, \omega_2)$.
>
> **Theorem.** If both sides are $n$-colourable, so is $G$; consequently $\chi(G) = \max(\chi_1, \chi_2)$.

<details>
<summary><b>Click to reveal the colour-permutation trick — the prettiest argument here</b></summary>

Let $c_1$ and $c_2$ be $n$-colourings of the two sides. Both are **injective on $K$**, because $K$ is a clique on each side. So $c_1|_K$ and $c_2|_K$ are two injections of the same $k$-element set into the same palette, and $c_2(v) \mapsto c_1(v)$ is a bijection between two subsets of the palette of equal size $k$; extend it to a **permutation $\sigma$ of all $n$ colours** by matching the complements. Recolour the right side by $\sigma \circ c_2$: still proper, and now it agrees with $c_1$ on every weld vertex. Glue. Every edge lies in one side, so every edge sees a proper colouring. $\blacksquare$

There is a bonus in that first sentence: injectivity on $K$ means **$k \le n$** automatically. In a genuine clique sum you never have to *assume* that there are at least as many colours as weld vertices.

</details>

{{algorithm:1}}

Putting the two together: if each side satisfies $\chi = \omega$, then so does the sum, since $\chi(G) = \max(\chi_1,\chi_2) = \max(\omega_1,\omega_2) = \omega(G)$. This is the numerical engine behind the classical fact that clique sums of [perfect graphs](https://en.wikipedia.org/wiki/Perfect_graph) are perfect.

---

## 7. The boundary: weaken the hypothesis and everything dies

Go back to the laboratory above, switch the weld mode to **weak**, and load **Witness B**: the triangle on $\{0,1,2\}$, with $G_1$ the single edge $0-1$ and $G_2$ the path $0-2-1$. Their union is the whole triangle, so $K = \{0,1,2\}$ is a $3$-clique of $G$ — but of *neither* side.

- **Colouring breaks:** each side is bipartite, so $\chi_1 = \chi_2 = 2$, while $\chi(G) = 3$. Here $n = 2 < 3 = k$, which we just proved impossible for a genuine clique sum.
- **Independence breaks:** $\alpha_1 = \alpha_2 = 2$ but $\alpha(G) = 1$, so $\alpha_1 + \alpha_2 = 4 > 3 = \alpha(G) + 2$ — even the corrected bound is destroyed.
- **Cliques break:** $\omega_1 = \omega_2 = 2$ while $\omega(G) = 3$; a clique of the union can straddle both sides once neither side realises the weld.

The moral: a separator is only a separator if **both sides agree about what happens inside it**. Otherwise the two summands jointly encode structure that neither of them individually sees.

---

## 8. From one weld to many

Real decompositions have many welds arranged in a tree. The trace formula is then a *fold*: each bag reports to its parent a table indexed by the trace left on the shared separator, and because that separator is a clique the table has $|K| + 1$ entries instead of $2^{|K|}$. That collapse — from exponential to linear in the separator size — is the whole payoff of the trace calculus, and it is the same phenomenon that makes junction-tree message passing and sparse-matrix elimination trees efficient.

{{algorithm:2}}

---

## 9. Check everything yourself

Finally, here is the complete numerical laboratory in Python: it rebuilds all four witnesses, computes every invariant by exhaustive search, prints a verdict for each composition law, verifies the One-Point Trace lemma over all graphs on four vertices, and stress-tests the theorems on randomly generated clique sums.

{{demo:0}}

---

## 10. What to take away

| invariant | what a witness carries across the weld | gluing law |
|---|---|---|
| independence number $\alpha$ | at most one weld vertex | $\alpha(G) = \max_{|T|\le1}(\alpha_1(T)+\alpha_2(T)-|T|)$ |
| clique number $\omega$ | nothing: cliques never cross | $\omega(G) = \max(\omega_1,\omega_2)$ |
| chromatic number $\chi$ | nothing, after permuting colours | $\chi(G) = \max(\chi_1,\chi_2)$ |

And three lessons. **Sharpness means all regimes**: $\min(k,2)$ is attained for $k = 0$, $1$ and $\ge 2$, and no single example could have revealed that shape. **A false folklore result is usually a missing clause**, not a missing idea — here, the requirement that the two optimisers agree on the weld. And **the right invariant to compose is a relativised one**: $\alpha_i$ does not compose, but $T \mapsto \alpha_i(T)$ does.

*Further reading:* [clique sums](https://en.wikipedia.org/wiki/Clique_sum), [chordal graphs](https://en.wikipedia.org/wiki/Chordal_graph), [treewidth](https://en.wikipedia.org/wiki/Treewidth), and the [independent set problem](https://en.wikipedia.org/wiki/Independent_set_(graph_theory)).
