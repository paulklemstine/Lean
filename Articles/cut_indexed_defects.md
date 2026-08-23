# Cutting a Code in Half: How One Inequality Explains Error Correction, Entropy, and Entanglement

## A single number, asked of every possible split

Imagine you are handed a message of $n$ symbols, each drawn from an alphabet of $q$ letters, and you are told that it belongs to some agreed-upon list $C$ of legal messages — a *code*. Now take a pair of scissors and cut the message into two pieces: a set $S$ of positions on the left, and everything else on the right.

Here is the question that will organise everything that follows:

> **How much does the left half need to know about the right half?**

There is a crisp way to make that precise. Look at all the legal messages in $C$, and record only what they look like on the positions in $S$. Different messages may agree there; the number of genuinely *distinct patterns* that appear on $S$ is a single integer, which we call the **cut rank** $r(S)$. It measures the width of the channel connecting the two halves: to reconstruct a codeword from its right half, all you need to be told is which of the $r(S)$ left-patterns you are looking at.

Physicists have their own name for this quantity. In a tensor network — the combinatorial scaffolding underlying modern descriptions of quantum many-body states — the analogous number is the **bond dimension** across the cut, and it controls how much entanglement can flow between the two sides. Coding theorists have yet another name for a close relative: the *generalised Hamming weight* profile of a code.

The story below is about what happens when you take this shared object seriously and ask what can be proved about it using nothing but its most primitive properties. The answer turns out to be: almost everything — including a sharpened form of the most famous inequality in coding theory, a matching statement about Shannon entropy that is strictly stronger, and a quantum-mechanical version whose failure to saturate has a beautiful geometric explanation.

---

## Three axioms, and nothing else

Strip away codes and tensor networks. What remains is a function assigning a positive integer to every subset of the $n$ sites, together with a "total dimension" $\mathrm{tot}$ — the size of the whole object being cut. Call the package **cut data**. It must satisfy just three rules:

1. **The empty cut is trivial:** $r(\varnothing) \le 1$. If you look at nothing, you see nothing.
2. **Monotonicity:** if $S \subseteq T$ then $r(S) \le r(T)$. Looking at more sites cannot reveal fewer patterns.
3. **One-site growth:** $r(S \cup \{a\}) \le q \cdot r(S)$. Adding a single site multiplies your view by at most the alphabet size.

That's it. Three axioms, all obviously true for the cut rank of a code, and all obviously true for the bond dimension of a tensor network.

The remaining ingredient encodes the *error-correcting power*. Say the cut data is **$d$-resolving** if every cut that misses fewer than $d$ sites already sees everything:
$$n - |S| < d \implies r(S) = \mathrm{tot}.$$
For a code, this is exactly the statement that its minimum distance is at least $d$: two codewords differing on fewer than $d$ positions must be equal, so any $n - d + 1$ positions pin a codeword down uniquely.

Out of these ingredients falls a number that everyone in coding theory knows: the **Singleton dimension**
$$k := n + 1 - d.$$

---

## The cut-wise Singleton inequality

The classical **Singleton bound**, proved in the 1960s, says that a code of length $n$ and minimum distance $d$ over an alphabet of size $q$ can contain at most $q^{n+1-d}$ codewords. It is the reason nobody ever announces a code that both corrects a lot of errors and carries a lot of information: you cannot have both.

Here is the sharpening. Not one inequality, but a whole family indexed by cuts.

> **Cut-Wise Singleton Inequality.** *Let cut data on $n$ sites with local dimension $q$ be $d$-resolving, with $d \ge 1$ and $k = n+1-d$. Then for every cut $S$ with $|S| \le k$,*
> $$\mathrm{tot} \;\le\; q^{\,k - |S|} \cdot r(S).$$

Setting $S = \varnothing$ and using $r(\varnothing) \le 1$ recovers the Singleton bound exactly. But for a nonempty cut the inequality says something genuinely new: *knowing how wide the bond is across any single cut already caps the size of the whole object.*

The proof is a two-line argument once you see it. Because $|S| \le k$, you can enlarge $S$ to a set $T$ of size exactly $k$. That set misses $n - k = d - 1$ sites, fewer than $d$, so by the resolving property $r(T) = \mathrm{tot}$. And by iterating the one-site growth axiom across the $k - |S|$ sites of $T \setminus S$, $r(T) \le q^{k-|S|} r(S)$. Chain the two facts and you are done.

What makes this satisfying is how *little* is used. No linear algebra, no field structure, no generator matrices — just a monotone function that grows slowly and saturates late.

---

## Rigidity: the codes that saturate it

The bound has a shadow side. Define the **cut-indexed defect**
$$\delta(S) \;=\; q^{\,k - |S|} r(S) \;-\; \mathrm{tot} \;\ge\; 0,$$
the slack in the inequality at the cut $S$. The codes that meet the Singleton bound globally — $\mathrm{tot} = q^k$, the celebrated **MDS** (maximum distance separable) codes, of which Reed–Solomon codes are the workhorse example — turn out to be exactly the objects with no slack anywhere.

> **Rigidity of Saturated Cut Data.** *If $\mathrm{tot} = q^k$ and $q \ge 1$, then for every cut with $|S| \le k$ we have $r(S) = q^{|S|}$ exactly, and consequently $\delta(S) = 0$.*

The proof is a squeeze: $q^k = \mathrm{tot} \le q^{k-|S|} r(S) \le q^{k-|S|} q^{|S|} = q^k$, so every inequality in the chain is an equality.

Translated back into coding language, $r(S) = q^{|S|}$ says that the projection of an MDS code onto *any* $k$ or fewer coordinates is **onto**: every pattern occurs. This is the classical theorem that in an MDS code, *every* set of $k$ coordinates is an information set — one can freely choose the symbols there and the rest of the codeword is determined. A short refinement of the same squeeze, applied to a fibre viewed as its own cut datum, shows more: each of the $q^{|S|}$ patterns has *exactly* $q^{k-|S|}$ codewords above it. MDS projections are perfectly balanced covering maps.

---

## Entropy: the same story, told better

The cut rank counts patterns. It does not care whether the patterns occur equally often or wildly unevenly. That is a loss of information, and information is precisely the currency we should be using.

So replace counting by **Shannon entropy**. Put the uniform distribution on the code $C$, project it onto the cut $S$, and let $p_S(y) = |\{c \in C : c|_S = y\}| / |C|$ be the resulting probability of the pattern $y$. Define the **cut entropy**
$$H(S) \;=\; -\sum_{y} p_S(y) \log p_S(y).$$
This is the classical shadow of the entanglement entropy across the cut: how many nats of information the sites in $S$ actually see.

The three axioms of cut data have exact entropic mirrors, and all three are theorems.

> **Mirror 1 (Vanishing at the empty cut).** $H(\varnothing) = 0$.

> **Mirror 2 (Monotonicity of the Entropy Profile).** *If $S \subseteq T$ then $H(S) \le H(T)$.*

Mirror 2 is not a formality. Coarse-graining a distribution can in general *raise* entropy; what saves us is that the coarse-graining here is deterministic — the marginal on $S$ is obtained by *summing* the fibres of the marginal on $T$ — and the function $x \mapsto -x\log x$ is **superadditive** on nonnegatives:
$$-\Big(\sum a_i\Big)\log\Big(\sum a_i\Big) \;\le\; \sum_i \big(-a_i \log a_i\big),$$
which follows because each $a_i \le \sum a_j$ makes $\log a_i \le \log \sum a_j$.

> **Mirror 3 (Entropic One-Block Growth).** *If $S \subseteq T$ then*
> $$H(T) \;\le\; H(S) + \big(|T| - |S|\big)\log q.$$

This is the chain rule: enlarging the cut by $m$ sites adds at most $m \log q$ nats. Its engine is a **grouping inequality** that deserves to be stated on its own, because it is the analytic heart of the whole entropic development:

> **Grouping Inequality.** *For nonnegative weights $p_i$ indexed by a finite set $F$ with $|F| \le N$,*
> $$\sum_{i \in F} \big(-p_i \log p_i\big) \;\le\; -A\log A + A \log N, \qquad A = \sum_{i\in F} p_i.$$

In words: splitting a lump of probability mass $A$ into at most $N$ pieces buys you at most $A\log N$ extra nats — the maximum being achieved when the pieces are all equal. The proof is the ubiquitous estimate $\log x \le x - 1$, applied to $x = A/(N p_i)$ and summed. What makes this version useful is that it is *relativised*: it bounds the entropy of a single block of the fine distribution against a single atom of the coarse one, which is exactly the shape you need inside a sum over all cuts.

Chain Mirror 3 with the resolving property and you get the sharpest form of the theory:

> **Entropic Cut-Wise Singleton Inequality.** *Let $C$ be a nonempty code of length $n$ over an alphabet of size $q \ge 1$ with minimum distance at least $d \ge 1$, and let $k = n+1-d$. Then for every cut $S$ with $|S| \le k$,*
> $$\log |C| \;\le\; H(S) + (k - |S|)\log q.$$

Because entropy never exceeds the log of the support size, $H(S) \le \log r(S)$, this **implies** the counting version — and it is strictly stronger whenever the marginal on $S$ is not uniform. A five-word code makes the gap visible: for $C = \{000, 100, 010, 110, 001\}$ and $S = \{1\}$, the two fibres have sizes $3$ and $2$, so $H(S) = -\tfrac35\log\tfrac35 - \tfrac25\log\tfrac25 \approx 0.673$ nats, strictly below $\log r(S) = \log 2 \approx 0.693$. Entropy sees the *shape* of the fibre distribution; rank sees only its support.

---

## The tent and the staircase

What does the entropy profile of a code actually look like as the cut grows?

> **The Entropy Plateau of MDS Codes.** *For an MDS code with minimum distance $d$ and $k = n+1-d$, at every cut,*
> $$H(S) = \min\big(|S|,\, k\big)\,\log q.$$

The profile climbs with the maximum possible slope $\log q$ per site, and then stops dead at $k$ — a discrete staircase with a sharp corner at the Singleton dimension. This is a lattice-theoretic cousin of the **Ryu–Takayanagi** curves that appear in holography, where entanglement entropy grows linearly and then plateaus once a minimal surface can no longer be enlarged.

The two halves of the proof are the two halves of the story so far. Below $k$, the balanced-fibre theorem makes the marginal exactly uniform on $q^{|S|}$ patterns, giving $H(S) = |S|\log q$. Above $k$, minimum distance makes the projection *injective*, so the marginal is uniform on all of $C$ and $H(S) = \log|C| = k \log q$.

There is a sharp converse, which is perhaps the most striking single statement in the theory:

> **Entropy Detects MDS at a Single Cut.** *Let $C$ be a nonempty code with minimum distance at least $d$, over an alphabet with $q \ge 2$, and let $S$ be any one cut of size exactly $k$. Then $C$ is MDS if and only if $H(S) = k \log q$.*

You do not have to average over cuts, or examine the whole profile. One cut of the right size, one number, and the entire Singleton defect is exposed. Equivalently, the **entropic defect** $H(S) + (k-|S|)\log q - \log|C|$ is always nonnegative, and at the empty cut it vanishes precisely for MDS codes.

---

## Going quantum, and why the picture changes

Now promote the code to a quantum state: the uniform superposition
$$|C\rangle = \frac{1}{\sqrt{|C|}} \sum_{c \in C} |c\rangle.$$
Every cut $S$ makes this a bipartite state, and one can ask for its **Schmidt rank** and **entanglement entropy** $E(S)$ across the cut.

Everything transfers — up to a point. The state factors through the space of realised patterns, so its Schmidt rank is at most the classical cut rank $r(S)$, and hence:

> **Quantum Cut-Wise Singleton Inequality.** *For a nonempty code with minimum distance at least $d\ge 1$,*
> $$E(S) \;\le\; \min\big(|S|,\, k\big)\,\log q,$$
> *the same plateau curve that bounds the classical cut entropy.*

And for MDS codes the bound is saturated — but only in a restricted range. If $|S| \le \min(k, d-1)$, the reduced state on $S$ is *exactly* the maximally mixed state on $q^{|S|}$ levels, so $E(S) = |S|\log q$ and the Schmidt rank is exactly $q^{|S|}$. The computation is pretty: the off-diagonal entries of the reduced density matrix count pairs of codewords that agree off $S$, and minimum distance annihilates them the moment $|S| < d$; the diagonal entries are the balanced fibre counts.

But the range genuinely matters, and here the quantum story parts ways with the classical one. A pure state has equal entanglement on both sides of a cut, so $E(S) = E(S^c) \le \min(|S|, |S^c|)\log q$ — the quantum profile is forced to come back *down*. Where the classical entropy profile is a monotone staircase, the quantum one is a **tent**.

The smallest example makes this concrete. Take the even-weight code $\{000, 011, 101, 110\}$ on three bits: $n=3$, $q=2$, $d=2$, $k=2$, and it is MDS. Its classical profile is
$$H(\varnothing), H(\text{1 site}), H(\text{2 sites}), H(\text{all}) \;=\; 0,\ \log 2,\ 2\log 2,\ 2\log 2,$$
a staircase that climbs and holds. Its quantum profile is
$$E = 0,\ \log 2,\ \log 2,\ 0,$$
a tent that climbs and falls (the middle value being provably at most $\log 2$, and in fact exactly $\log 2$). At the two-site cut the quantum entropy is *strictly less* than the classical one, even though the code is MDS — the purity of the global state forbids more than $\log 2$ of entanglement when only one qubit remains on the other side. The guard $|S| < d$ in the saturation theorem is not an artefact of the proof; it is real.

And at the full cut of the same code, the classical entropic defect is exactly $3\log 2 - 2\log 2 = \log 2 > 0$: the third bit carries no new information, and the defect records it.

---

## One more surprise: entropy is better behaved than rank

Shannon entropy is famously **submodular**: $H(S) + H(T) \ge H(S\cup T) + H(S \cap T)$. One might hope the cut rank inherits this. It does not.

> **The Cut Rank Is Not Submodular.** *For $C = \{000, 100, 010, 110, 001\}$ and the cuts $S = \{1,3\}$, $T = \{2,3\}$,*
> $$r(S)\,r(T) = 3 \cdot 3 = 9 \;<\; 10 = 5 \cdot 2 = r(S \cup T)\, r(S \cap T).$$

So $\log r$ violates an inequality that $H$ always satisfies. This is not a defect of the example; it is the structural reason entropy is the better invariant, and the reason the entropic defect can detect the MDS property at a single cut while the counting defect cannot. Rank sees which patterns occur; entropy weighs them, and the weighting is exactly what restores the good behaviour.

---

## Why it matters

The moral is one that recurs across mathematics: a theorem that looks like it belongs to one subject often belongs to a much thinner axiom system, and once you find that system, the theorem multiplies.

The Singleton bound was a statement about codes. It turns out to be a statement about *any* monotone, slowly-growing, eventually-saturating function on the subsets of a finite set — which includes bond dimensions of tensor networks, ranks of matroids, and entanglement structures of quantum states. Along the way we get the classical theorem that every $k$ coordinates of an MDS code form an information set, a discrete Ryu–Takayanagi plateau, a one-cut criterion for optimality, and a sharp demarcation between the classical and quantum invariants.

The open ends are inviting. Is the cut entropy submodular, making the profile a genuine *polymatroid* and the entropic defect a matroid invariant? Does the entropy profile determine the code's family of information sets? And does the two-sided sandwich $|S|\log q \le I(A{:}B) \le 2|S|\log q$ for the quantum mutual information of an MDS code state collapse to the upper end, as purity suggests it must? Each is a concrete question about a single scalar attached to a single cut — the kind of question that, as this whole story shows, tends to have a short and structural answer.
