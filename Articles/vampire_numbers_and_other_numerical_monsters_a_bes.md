# Vampire Numbers and the Modular Trap Hidden in Their Digits

## When multiplication becomes a masquerade

The number $1260$ looks ordinary until it is asked to reveal its factors. It answers:

$$
1260=21\times 60.
$$

Now compare the decimal digits on the two sides. The product uses $1,2,6,0$; its factors, read together, use $2,1,6,0$. Nothing has been added and nothing has vanished. Multiplication has merely rearranged the cast.

That coincidence makes $1260$ the smallest classical **vampire number**. More precisely, a positive composite integer $v$ with an even number of decimal digits is a vampire number if it can be written as $v=xy$, where the two factors—traditionally called **fangs**—have equal length, and the multiset of digits in $x$ followed by the digits in $y$ is exactly the multiset of digits in $v$. “Multiset” matters: repeated digits must occur with the same multiplicities. Standard conventions also forbid both fangs from ending in zero, to rule out easy padding tricks.

Vampire numbers belong to a playful bestiary of digit-constrained products. One may imagine **werewolf products**, in which the factors and product share a prescribed small number of digit values, or **ghost products**, in which the product shares no digit value at all with either factor. A particularly sharp variant asks for both fangs to be prime. We shall call such a factorization a **prime-fang vampire factorization**. Unlike the classical definition, this notion focuses on the common combinatorial heart of the phenomenon: the product relation and exact preservation of the decimal digit multiset.

These creatures are easy to describe and expensive to hunt. A naive search must factor many integers, split candidates into equal-length fangs, and compare digit inventories. Yet decimal notation is not mere decoration. It carries an algebraic shadow, and that shadow places every possible pair of fangs on a tiny modular curve.

## Casting out nines

The key is the familiar divisibility test for nine. Because $10\equiv 1\pmod 9$, every nonnegative integer is congruent modulo nine to the sum of its decimal digits. For example,

$$
1260\equiv 1+2+6+0\equiv 0\pmod 9.
$$

If the digits of $x$ and $y$ are rearranged to form the digits of $v$, then their digit sums agree exactly. Consequently,

$$
v\equiv x+y\pmod 9.
$$

But $v=xy$, so every digit-permutation factorization satisfies

$$
xy\equiv x+y\pmod 9.
$$

Rearranging gives the more revealing equation

$$
(x-1)(y-1)\equiv 1\pmod 9.
$$

This is the **decimal residue-curve condition**. A combinatorial requirement involving every digit has collapsed to one equation involving only two residues.

There are eighty-one ordered residue pairs modulo nine, but the curve admits only six. The **six-point residue theorem** says that any digit-permutation factorization $v=xy$ must have

$$
(x\bmod 9,y\bmod 9)\in
\{(0,0),(2,2),(3,6),(5,8),(6,3),(8,5)\}.
$$

The proof is short enough to see in full. Set $a=x-1$ and $b=y-1$. The equation becomes $ab\equiv1\pmod9$, so $a$ must be a unit modulo nine. The units are $1,2,4,5,7,8$. Pairing each with its multiplicative inverse and then adding one to both coordinates yields exactly the six pairs above. Thus more than nine out of every ten ordered residue pairs are impossible before a single digit histogram is compared.

This sieve is necessary, not sufficient. Passing it does not make a number vampiric. It simply means the candidate has survived a cheap and universal obstruction. That distinction is crucial: modular arithmetic can close doors instantly, but it does not promise that anything lives behind the doors left open.

## What primality removes

Now impose the condition that both fangs are prime. The six points collapse to three.

The elementary bridge is this: if a prime is divisible by $3$, then it equals $3$. In particular, no prime is congruent to $0$ or $6$ modulo nine. A prime congruent to $3$ modulo nine would have to be the prime $3$ itself.

Apply these facts to the six residue pairs. The pair $(0,0)$ is impossible because both entries are divisible by nine. The pair $(3,6)$ is impossible because its second entry is divisible by three and cannot be prime; the exceptional possibility that the first fang equals $3$ does not rescue its partner. The reversed pair $(6,3)$ fails symmetrically. Exactly three points remain.

**Prime-Fang Residue Theorem.** If $v=xy$ is a decimal digit-permutation factorization and both $x$ and $y$ are prime, then

$$
(x\bmod9,y\bmod9)\in\{(2,2),(5,8),(8,5)\}.
$$

Each surviving pair has the same product residue:

$$
2\cdot2\equiv5\cdot8\equiv8\cdot5\equiv4\pmod9.
$$

This proves the central concentration law.

**Prime-Fang Concentration Law.** Every decimal digit-permutation product with two prime fangs satisfies

$$
v\equiv4\pmod9.
$$

A direct corollary is that $3\nmid v$. Indeed, a number congruent to $4$ modulo nine is congruent to $1$ modulo three.

The strength of this result lies in its universality. It is not an observation from a finite list, and it does not depend on the number of digits. Whether the fangs have two digits or two million, a prime-fang candidate outside the residue class $4$ modulo nine is impossible.

## A search that respects the mathematics

Suppose we wish to search for classical vampire numbers with two $n$-digit fangs. The blunt method loops through all pairs $x,y$ in the interval $[10^{n-1},10^n)$, multiplies them, and compares sorted digit strings. The residue theorem suggests a better order.

First, retain only pairs whose residues belong to the six-point set. Second, compute $v=xy$ and reject products with the wrong length. Third, compare digit-frequency vectors: for each decimal digit $d$, count its occurrences in $x$ and $y$, and ask whether their sum equals its count in $v$. Finally, apply conventional exclusions such as the ban on two trailing-zero fangs.

For prime fangs the filter is even narrower. Generate primes in the fang interval, sort them into residue classes $2$, $5$, and $8$ modulo nine, and test only class pairings $(2,2)$, $(5,8)$, and $(8,5)$. Equivalently, any product not congruent to $4$ modulo nine can be discarded immediately. The result is not a complete factoring algorithm; digit-constrained multiplication remains difficult. But it turns a thematic curiosity into a structured search problem.

The same philosophy reaches beyond recreational number theory. Checksums exploit the fact that complicated data leave simple modular fingerprints. Hash tables reject mismatches before expensive comparisons. Constraint solvers propagate inexpensive local restrictions before exploring global configurations. Here, the decimal digit sum is a checksum, and the modular curve is the propagated constraint.

## Other monsters in the menagerie

The ghost-number idea illustrates why precise definitions matter. A balanced version begins with two $n$-digit factors $x$ and $y$ whose product has $2n$ digits, and requires the product to use none of the digit values appearing in either factor. This is not a permutation problem, so the residue curve above does not apply directly. Its governing force is instead alphabet avoidance. If the factors collectively use many of the ten decimal symbols, the product is forced to draw all its digits from a small complementary alphabet. As length grows, that demand should become increasingly severe.

Likewise, “werewolf” can mean several inequivalent things. Sharing exactly one digit could refer to one occurrence, one distinct digit value, or one digit shared by each fang separately. A sound theory must choose one. Such definitional care is not pedantry: different choices produce different counting problems and different asymptotic behavior.

The phrase “zombie number” has also been used inconsistently, sometimes for two prime fangs and sometimes for examples involving one prime and one composite factor. The prime-fang theory developed here uses the literal and mathematically clean requirement that both fangs are prime. Under that definition, the three-point sieve and residue-$4$ concentration law follow without ambiguity.

## What remains unknown

The modular trap settles a local question, but several global questions remain open.

Let $V(n)$ be the proportion of $2n$-digit integers admitting a classical vampire factorization with two $n$-digit fangs. A provocative hypothesis predicts a scale like $V(n)\asymp n^{-1/2}$. A precise version asks whether $\sqrt n\,V(n)$ tends to a positive finite constant. Any serious model must combine multinomial digit occupancy with the residue curve; counting digit permutations alone ignores multiplication’s modular fingerprint.

A second challenge asks whether every interval

$$
[10^{2k},10^{2k+2})
$$

contains a classical vampire number. Isolated examples do not establish a uniform construction, and a successful family would need to control both the leading digits of a product and its complete digit multiset.

For prime fangs, the natural question is infinitude. Are there infinitely many digit-permutation products with both fangs prime? Every candidate is now known to lie on one of only three residue pairings, and every product lies in the single class $4$ modulo nine. This is a powerful local obstruction, but local admissibility is far from existence.

Finally, the balanced ghost problem asks whether the proportion of factor pairs with complete digit-value avoidance tends to zero, perhaps exponentially fast. Entropy and occupancy estimates suggest that it should, but multiplication carries couple the digits in ways that simple independent models do not capture.

Vampire numbers are jokes with teeth. Their names invite us in, but their substance is a genuine meeting of elementary number theory, combinatorics, primality, and computation. The decisive lesson is broader than the creatures themselves: when a global pattern seems too intricate to grasp, look for the small algebraic shadow it cannot avoid. In this bestiary, every digit may wear a disguise, but modulo nine the monster still leaves tracks.
