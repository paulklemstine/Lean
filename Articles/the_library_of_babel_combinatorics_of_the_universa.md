# The Library of Babel, Counted

## Every book exists. The hard part is finding one.

Imagine a library whose shelves contain every possible book of a fixed length. Not every sensible book, not every grammatical book, but every sequence that can be formed from a chosen alphabet. Somewhere there is a flawless history of tomorrow. Nearby are its millions of near-copies, each with one letter changed. There are proofs, refutations, love letters, weather reports, and oceans of punctuation-free noise.

This is the mathematical core of Jorge Luis Borges’ Library of Babel. Once stripped of architecture and mythology, it becomes a finite combinatorial universe. Let the alphabet have $q$ symbols, and let every book contain exactly $n$ symbol positions. A book is then a function assigning one of the $q$ symbols to each of the $n$ positions—or, more familiarly, a word of length $n$ over a $q$-letter alphabet.

The first result is simple and decisive: the library contains exactly

$$
q^n
$$

books. Each position offers $q$ independent choices, and multiplying those choices over $n$ positions gives the total.

For the traditional parameters of a $25$-symbol alphabet and $1{,}312{,}000$ symbol positions, the number of volumes is

$$
25^{1{,}312{,}000}.
$$

It is finite. It is also so large that writing its decimal expansion would itself require roughly $1.83$ million digits. The Library of Babel is therefore a perfect lesson in the difference between existence and accessibility. Every volume can exist in the mathematical collection while nearly every practical search remains hopeless.

## Giving every book an address

A universal library needs more than shelves; it needs addresses. Fortunately, the books themselves suggest a canonical catalog.

Number the alphabet symbols $0,1,\ldots,q-1$. If a book has symbols $a_0,a_1,\ldots,a_{n-1}$, read those symbols as the digits of a base-$q$ number:

$$
A(a_0,a_1,\ldots,a_{n-1})
= a_0q^{n-1}+a_1q^{n-2}+\cdots+a_{n-1}.
$$

This address always lies between $0$ and $q^n-1$. More importantly, no two books receive the same address, and every address in that range belongs to exactly one book. This is the **Canonical Address Theorem**: length-$n$ words over a $q$-symbol alphabet are in one-to-one correspondence with the integers $0,1,\ldots,q^n-1$.

The proof is the familiar uniqueness of base-$q$ notation. To recover a book from its address, repeatedly divide by $q$ and record the remainders. Each remainder is a symbol. Thus cataloging and retrieval are not mysterious operations: both require only a number of arithmetic steps proportional to the book length, apart from the cost of manipulating very large integers.

This point resolves an apparent paradox. A catalog of every individual book need not be printed as a gigantic table. A short rule can assign every location. A formula is not the same thing as a list.

Consider a miniature but still substantial example: an alphabet of four symbols and books of length sixteen. Its population is

$$
4^{16}=4{,}294{,}967{,}296.
$$

Every one of these more than four billion books has a unique base-four address. The book $[3,1,0,2]$, in a four-symbol library of length four, has address

$$
3\cdot 4^3+1\cdot 4^2+0\cdot 4+2=210.
$$

Dividing $210$ repeatedly by $4$ recovers the remainders and therefore the original book. The mini-library is universal for its chosen dimensions, yet its cataloging rule fits in a paragraph.

## How rare is a particular meaningful text?

Suppose one book is chosen uniformly at random. What is the chance of drawing a specified text? Since there are $q^n$ books and each is equally likely, the **Uniform Text Theorem** says that the exact probability is

$$
\Pr(\text{specified book})=\frac{1}{q^n}.
$$

For the full $25$-symbol library, that probability is $25^{-1{,}312{,}000}$. Existence alone offers essentially no practical comfort.

But meaningful targets are often not single texts. A fixed rule may accept many books: perhaps those encoding syntactically valid arguments, perhaps those passing a bounded mathematical checker, or perhaps those containing a chosen phrase. Let $C$ be any yes-or-no test on books, and let $M$ be the number of books it accepts. Then the **Acceptance Probability Theorem** states

$$
\Pr(C\text{ accepts a random book})=\frac{M}{q^n}.
$$

This is exact, not an approximation. If at least one accepted witness is known, then $M>0$, so the probability is positive. Yet “positive” can still mean fantastically small.

This formula also clarifies why there is no single universal numerical answer to “What is the probability of finding a valid proof?” The question must first specify the alphabet or byte encoding, the theorem being proved, the grammar, the allowed background assumptions, the checker, and any limits on time or memory. Different rules accept different subsets and therefore produce different values of $M$. Once all those choices are fixed as a finite yes-or-no procedure, the probability is exactly the fraction above.

A useful special case concerns a target pattern of length $k$. At one specified position, the chance of matching it is $q^{-k}$. Across $r$ candidate positions, the expected number of matches is $rq^{-k}$. The probability of at least one occurrence is at most $rq^{-k}$ by the union bound. This explains the common heuristic “number of opportunities times $q^{-k}$,” while also showing its limits: overlaps make the events dependent, so the heuristic need not be an exact probability.

## The catalog that cannot fit in one book

Now comes the deeper distinction. A canonical catalog can have a short description, but what if “catalog” means an arbitrary table assigning an address or destination to every book?

Let $L=q^n$ be the number of books. A table with one book-valued entry for each of the $L$ books is a function from an $L$-element set to itself. There are

$$
L^L=(q^n)^{q^n}
$$

such tables. A single volume, however, has only $L$ possible contents. Whenever $L\ge 2$, we have $L^L>L$. Therefore no injective encoding from all possible catalog tables into individual books can exist.

This is the **Universal Table Impossibility Theorem**: if a library contains at least two books, one book cannot uniquely represent every possible complete book-to-book table.

The argument is pure counting. If more objects must be encoded than there are codewords, collisions are unavoidable. It does not say that the useful base-$q$ catalog is impossible; that catalog is one specially structured function with a concise rule. The theorem says that every possible table cannot be compressed injectively into the same book format.

The difference resembles the gap between describing “sort these names alphabetically” and printing an unrelated destination beside every possible name. Structure can collapse a description. Arbitrary data cannot be expected to do so.

## When a catalog is spread across many volumes

If one volume is insufficient, distribute the information. Suppose there are $T$ distinct records to store, $N$ books available, and each book has room for $c$ records. Exactly when is storage possible?

The **Distributed Capacity Theorem** gives a complete answer:

$$
T\le Nc.
$$

Necessity is immediate: $N$ books with $c$ slots each provide only $Nc$ slots. Sufficiency is constructive. Number records $0$ through $T-1$. Put record $i$ in book $\lfloor i/c\rfloor$ and slot $i\bmod c$. The inequality guarantees that the selected book number is below $N$.

This theorem is elementary, but it captures a central principle of information systems. A distributed index, a sharded database, and a bank of storage drives all obey the same arithmetic. Capacity adds.

It also repairs an easy mistake in reasoning about the Library. One may estimate a book’s bit capacity as $n\log_2 q$, but exact storage claims should specify what counts as a record and how symbols encode it. The slot theorem avoids ambiguity: once capacity is measured in fixed records, the criterion is both necessary and sufficient.

## A guide is not the territory

The Library of Babel dramatizes a truth now familiar from search engines, scientific databases, and generative systems: abundance is not knowledge. A space can contain every answer while providing no efficient path to the answer one wants.

The canonical address map proves that every book can be named and recovered. The probability formulas measure how little that helps random search. The table-counting theorem marks the boundary between a concise structured rule and arbitrary information. The distributed-capacity theorem shows how more physical carriers can overcome a fixed local limit.

One famous route to a more compact traversal uses a de Bruijn cycle: a cyclic sequence in which every length-$n$ word over a $q$-symbol alphabet appears exactly once as a consecutive cyclic window. Such a cycle has length $q^n$. For the four-symbol, order-sixteen case, its cyclic length would be $4^{16}$. Building and proving the required cycle is a further step beyond the base-four address catalog described here; the two should not be confused. The address catalog enumerates words by arithmetic, while a de Bruijn cycle arranges them as overlapping windows of one cyclic object.

That future construction would sharpen the Library’s central metaphor. Neighboring books could overlap in all but one symbol, turning exhaustive enumeration into a walk through a graph. Yet even the current results already expose the essential tension. The whole universe of fixed-length texts is finite, countable, addressable, and exactly measurable. Meaning remains sparse because counting what exists is not the same as recognizing what matters.

Borges imagined librarians wandering hexagons in despair. Combinatorics gives them coordinates, probabilities, and capacity bounds. It cannot tell them which sentence is true. That final act still belongs to interpretation—and that is why a library containing everything can feel so much like a library containing nothing.