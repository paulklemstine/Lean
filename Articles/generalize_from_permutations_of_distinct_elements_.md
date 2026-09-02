# The Price of Forgetting a Tie

## What sorting really destroys, when the things you sort are not all different

Every time a computer sorts a list, it commits a small act of destruction.

Think about what sorting *does*. You hand it a jumbled sequence — say the five numbers $7, 2, 9, 2, 5$ in that order — and it hands back $2, 2, 5, 7, 9$. The output is tidy. It is also **amnesiac**: from the sorted list alone, you cannot recover the order you started with. The sorted list is the same no matter which of the many possible shufflings you fed in. Sorting is a many-to-one map, and every many-to-one map throws away information.

How much? For $n$ items that are all distinct, the answer is famous and clean. There are $n!$ possible input orders, all collapsing to one output, so sorting erases
$$\log_2(n!) \text{ bits.}$$
This single number is the hidden spine of computer science's most quoted lower bound: a comparison sort needs at least $\log_2(n!) \approx n\log_2 n$ comparisons, because each comparison answers one yes/no question, and you need enough questions to pin down which of the $n!$ orders you were given.

It is also a *physical* number. Rolf Landauer observed in 1961 that erasing information is not free: destroying one bit in a system at temperature $T$ must dissipate at least $kT\ln 2$ joules of heat, where $k$ is Boltzmann's constant. So sorting $n$ distinct items has an unavoidable thermodynamic price tag of at least $kT\ln(n!)$ joules — no matter how clever your algorithm, no matter what technology implements it. Charles Bennett's reversible computing showed the flip side: if you refuse to pay, you must *keep* the erased information somewhere, in at least $n!$ distinguishable "history" states.

That is the story for distinct items. But real data is not distinct. Real data has ties. Sort a million customer records by country code and you have maybe two hundred distinct keys among a million slots. Sort DNA by nucleotide and there are four. Sort a bit vector and there are two. What happens to the ledger then?

## Ties are free

Here is the punchline, and it is worth pausing on because it is both obvious in hindsight and quantitatively sharp.

If two items carry the *same key*, then swapping them changes nothing you could ever observe. They are not two inputs; they are one input. The sorting map never had to forget the difference between them, because there was no difference to forget.

Make this precise. Model an input as a **key word**: a function $w$ assigning to each of the $n$ slots a key drawn from an alphabet of $r$ possible keys. Let $m_i$ be the **multiplicity** of key $i$ — how many slots carry it — so that $m_1 + m_2 + \cdots + m_r = n$. Two key words are the same input exactly when they are equal as functions; the genuinely distinguishable inputs are the **rearrangements** of $w$, that is, all the words you get by permuting the slots.

How many rearrangements are there? Not $n!$, because permuting two slots with the same key gives you back the word you started with. The permutations that leave $w$ completely unchanged are exactly those that shuffle within each block of equal keys, and there are $m_1!\,m_2!\cdots m_r!$ of them. Orbit–stabiliser bookkeeping then gives the exact, division-free identity
$$(\text{number of distinguishable inputs}) \times \prod_i m_i! \;=\; n!,$$
so the number of distinguishable inputs is the **multinomial coefficient**
$$\binom{n}{m_1,\ldots,m_r} \;=\; \frac{n!}{m_1!\,m_2!\cdots m_r!}.$$

And therefore the information erased by sorting a multiset is
$$\boxed{\;E \;=\; \log_2\!\left(\frac{n!}{\prod_i m_i!}\right)\;\text{bits.}}$$

Taking logarithms of the orbit–stabiliser identity gives an exact **conservation law**:
$$\log_2(n!) \;=\; \underbrace{\log_2\!\frac{n!}{\prod_i m_i!}}_{\text{what sorting a multiset erases}} \;+\; \underbrace{\sum_i \log_2(m_i!)}_{\text{what it never sees}}.$$
The classical factorial baseline splits, exactly and with no remainder, into two accounts: the information a multiset sorter really does destroy, and the information about the internal order *within* each block of equal keys — which no multiset sorter ever learns, and therefore never has to erase.

The consequences are immediate and pleasingly extreme. If all keys are distinct, every $m_i \le 1$, the second account is empty, and we recover $\log_2(n!)$ exactly: the classical answer is the special case. If all keys are *identical*, there is a single rearrangement, and the erased information is $\log_2 1 = 0$ — sorting a constant list is not merely fast, it is thermodynamically free. And as soon as *any* key occurs twice, the discount is strict: you save at least $\log_2(m_i!)$ bits, permanently, and the corresponding Landauer heat $kT\ln(m_i!)$ is never dissipated.

For the tiny example $A,A,B,B$: there are $4!/(2!\,2!) = 6$ distinguishable inputs, so sorting erases $\log_2 6 \approx 2.585$ bits rather than the $\log_2 24 \approx 4.585$ bits the distinct-key baseline would charge. Exactly $2$ bits — $\log_2(2!) + \log_2(2!)$ — are refunded.

The same bookkeeping refines the comparison lower bound. Any sorter that asks $d$ questions with $q$ possible answers each must distinguish all $n!/\prod m_i!$ inputs, so it needs
$$d \;\ge\; \left\lceil \log_q\!\frac{n!}{\prod_i m_i!}\right\rceil$$
queries — and this bound is achieved by an abstract decision procedure, so it is the exact information-theoretic cost, not a lossy estimate. Sorting four items $A,A,B,B$ needs at least $3$ comparisons, not the $5$ the factorial bound would demand.

## Entropy enters

So far this is combinatorics. The beautiful part is what the erasure ledger looks like from the point of view of information theory.

Read the multiplicities as a probability distribution: let $p_i = m_i/n$ be the fraction of slots carrying key $i$ — the **empirical key distribution**. Shannon's entropy of that distribution,
$$H(p) \;=\; -\sum_i p_i \log_2 p_i,$$
measures the average surprise, in bits, of learning one randomly chosen key. Then the total "entropy budget" of the word is $n\,H(p)$ bits, and the central inequality of this story is the **Shannon ceiling**:
$$\log_2\!\left(\frac{n!}{\prod_i m_i!}\right) \;\le\; n\,H(p).$$

Sorting a multiset can never erase more than the entropy of its own key statistics allows. Equivalently, in physical units, the unavoidable heat of a multiset sort obeys
$$W \;\le\; kT\ln 2 \cdot n\,H(p).$$

What makes this pleasant is *how* the ceiling is proved. No Stirling approximation, no analysis, no asymptotics — just one line of exact algebra. Expand $1 = (p_1 + \cdots + p_r)^n$ by the multinomial theorem:
$$1 \;=\; \sum_{k_1+\cdots+k_r=n} \binom{n}{k_1,\ldots,k_r}\, p_1^{k_1}\cdots p_r^{k_r}.$$
Every term on the right is non-negative, so *any single term is at most $1$*. Keep the one indexed by the actual multiplicity vector $k = m$:
$$\binom{n}{m_1,\ldots,m_r}\prod_i \left(\frac{m_i}{n}\right)^{m_i} \;\le\; 1.$$
Take logarithms, and $\log_2\binom{n}{m_1,\ldots,m_r} \le \sum_i m_i \log_2(n/m_i) = n H(p)$ falls out. That's it. The whole entropy ceiling is the statement that one term of a sum of positive numbers adding to one cannot exceed one.

The same argument tells you when the ceiling is *not* tight, and this is the sharper result. If two distinct keys both actually occur, then there is a second, strictly positive term in the expansion — take the multiplicity vector $m$ and move one unit from key $i$ to key $j$. Two positive terms summing to at most $1$ means the first is strictly less than $1$, and so
$$\log_2\!\left(\frac{n!}{\prod_i m_i!}\right) \;<\; n\,H(p) \qquad\text{whenever the multiset is genuinely mixed.}$$
The Shannon ceiling is *never attained* by a real multiset with more than one key present. It is an honest upper bound, approached but not reached — for $A,A,B,B$, $\log_2 6 \approx 2.585$ against a budget of exactly $4$. (The gap is the familiar $O(r\log n)$ Stirling correction, and closing it from below is the natural next problem.)

There is a cruder ceiling too, which comes free: a rearrangement is just a word of length $n$ over an alphabet of $r$ symbols, so there are at most $r^n$ of them, and the erasure is at most $n\log_2 r$ bits. Since $H(p) \le \log_2 r$ always, the Shannon ceiling is the better of the two — as it should be.

## Merging keys can only help

Now a structural law with a distinctly information-theoretic flavour.

Suppose you decide you no longer care about the difference between two keys — you stop distinguishing "blue" and "navy" and call them both "blue". Formally, you post-compose the key word with a merging map $g$ on the alphabet. What happens to the erasure ledger?

It can only go down. Every rearrangement of the coarsened word is the image of a rearrangement of the original, so
$$\#\{\text{rearrangements of the coarser word}\} \;\le\; \#\{\text{rearrangements of the finer word}\},$$
hence the erased information, and hence the Landauer heat, can only decrease. This is a genuine **data-processing inequality** for keys: you cannot manufacture distinguishability by forgetting distinctions.

Concretely: the word $A,A,B,B,C$ has $5!/(2!2!1!) = 30$ rearrangements ($\log_2 30 \approx 4.907$ bits). Merge $C$ into $B$ and you get $A,A,B,B,B$ with $5!/(2!3!) = 10$ rearrangements ($\log_2 10 \approx 3.322$ bits). Coarsening cost you $\log_2 3$ bits of erasure — and saved you the corresponding heat.

## Merging *lists* costs exactly the interleaving

The complementary operation is concatenation. Take a multiset $A$ of $n$ items and a multiset $B$ of $n'$ items over *disjoint* key alphabets, and consider them as one task. The number of distinguishable inputs multiplies with an extra factor:
$$\binom{n+n'}{n}\cdot \#\{\text{rearrangements of } A\}\cdot \#\{\text{rearrangements of } B\},$$
and hence the erasure ledger reads
$$E(A \sqcup B) \;=\; E(A) + E(B) + \log_2\binom{n+n'}{n}.$$

The third term is exactly the information in the **interleaving pattern**: which of the $\binom{n+n'}{n}$ ways the two sorted blocks are shuffled together. This is the information-theoretic shadow of the textbook fact that merging two sorted lists of lengths $n$ and $n'$ costs about $\log_2\binom{n+n'}{n}$ comparisons. Here it is not an estimate of an algorithm's cost but an exact term in a conservation law: the merge term is precisely the difference between doing the two tasks separately and doing them together. Since it is non-negative, concatenation never erases *less* than the two tasks apart.

Note the pleasing duality. Merging *keys* (coarsening the alphabet) decreases erasure. Merging *lists* (concatenating the data) increases it, by exactly the entropy of the interleaving.

## Why any of this matters

Three reasons, in increasing order of ambition.

**It sharpens a classical bound.** The $\log_2(n!)$ comparison lower bound is taught everywhere, and everywhere it is immediately followed by the caveat "but if there are ties you can do better". The multinomial ledger is what "better" means, exactly, with a matching achievability statement. Radix sorts, counting sorts, and bucket sorts beat $n\log n$ on low-entropy data not by cheating the information bound but by living underneath a *smaller* one.

**It gives sorting a temperature.** Landauer's principle turns every one of these logarithms into joules. A device that sorts a stream whose key distribution has entropy $H(p)$ bits per item cannot dissipate less than $kT\ln 2$ times $\log_2(n!/\prod m_i!)$ joules — and cannot be forced to dissipate more than $kT\ln 2 \cdot nH(p)$. Low-entropy data is not just faster to sort; it is *cooler*. That is a statement about hardware, not about asymptotics, and for the extremely large, extremely repetitive sorts that dominate real data centres it is the physically relevant one.

**It says something about what "information" means.** The whole development is one idea applied repeatedly: the information in a structure is the logarithm of the number of things it could have been, once you have agreed on what "different" means. Change the notion of difference — merge two keys, refuse to distinguish two slots — and the number changes in a controlled, monotone way. The conservation law $\log_2(n!) = \log_2(n!/\prod m_i!) + \sum_i \log_2(m_i!)$, the coarsening inequality, and the merge ledger are all instances of the same accounting discipline, the one that says information is never created, only reallocated between the part you erase and the part you never had.

## The open edge

The Shannon ceiling $\log_2(n!/\prod m_i!) \le nH(p)$ is proved, and proved strict for mixed multisets. What is missing is the matching floor:
$$n\,H(p) - O(r\log n) \;\le\; \log_2\!\left(\frac{n!}{\prod_i m_i!}\right).$$
This is true — it is the standard type-counting estimate — but the natural proof from the multinomial expansion needs one more ingredient: that among all multiplicity vectors $k$ summing to $n$, the term $\binom{n}{k}\prod_i p_i^{k_i}$ is *largest* at $k = m$, the empirical vector itself. That is a statement of mode rigidity, and it should follow from a purely local exchange argument: moving one unit of multiplicity from key $i$ to key $j$ multiplies the term by $k_i p_j / ((k_j+1)p_i)$, a ratio you can sign by inspection. Chain such local moves along a shortest path from $k$ to $m$ and the mode statement should fall.

Close that, and the ceiling becomes a sandwich: the erased information of sorting a multiset is $nH(p)$ up to $O(r\log n)$ bits, exactly. The physical statement then becomes an equality up to a vanishing correction — the heat of sorting *is* the entropy of the data. It is a satisfying place for a ledger to end up: not a bound, but a balance.

