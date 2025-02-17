(*<*)
theory Guarantees
  imports
      Core.SemanticsTypes
      Core.MoneyPreservation
      Core.Timeout
      Core.QuiescentResult
      Core.SingleInputTransactions
      Core.CloseSafe
      Core.TransactionBound

begin
(*>*)

chapter \<open>Marlowe Guarantees\<close>

text \<open>We can also use proof assistants to demonstrate that the Marlowe semantics presents certain
desirable properties, such as that money is preserved and anything unspent is returned to users by
the end of the execution of any contract.\<close>

subsubsection \<open>Auxillary Functions\label{sec:playTrace}\<close>

text \<open>Many of the proofs in this chapter rely on function @{const playTrace} and
@{const playTraceAux} that execute a sequence of transactions using the Marlowe semantics defined in
@{const computeTransaction}. They also rely on starting from a valid and positive contract state,
@{const validAndPositive_state} and a function @{const maxTimeContract} that extracts the latest
timeout from the contract.\<close>

text \<open>@{const playTrace} :: @{typeof playTrace}\<close>
text \<open>@{const playTraceAux} :: @{typeof playTraceAux}\<close>
text \<open>@{const validAndPositive_state} :: @{typeof validAndPositive_state}\<close>
text \<open>@{const maxTimeContract} :: @{typeof maxTimeContract}\<close>

section \<open>Money Preservation\<close>

text \<open>

One of the dangers of using smart contracts is that a badly written one can potentially lock its
funds forever. By the end of the contract, all the money paid to the contract must be distributed
back, in some way, to a subset of the participants of the contract. To ensure this is the case we
proved two properties: ``Money Preservation'' and ``Contracts Always Close''.

Regarding money preservation, money is not created or destroyed by the semantics. More specifically,
the money that comes in plus the money in the contract before the transaction must be equal to the
money that comes out plus the contract after the transaction, except in the case of an error.

\<close>

text \<open>@{thm playTrace_preserves_money}\<close>

text \<open>where @{const moneyInTransactions} and @{const moneyInPlayTraceResult} measure the funds in
the transactions applied to a contract versus the funds in the contract state and the payments that
it has made while executing.\<close>

section \<open>Contracts Always Close\<close>

text \<open>

For every Marlowe Contract there is a time after which an empty transaction can be issued that will
close the contract and refund all the money in its accounts.

FIXME: This theorem doesn't actually prove the narrative. Are we missing a theorem?

\<close>

text \<open>@{thm timeOutTransaction_closes_contract2}\<close>

section \<open>Positive Accounts\<close>

text \<open>

There are some values for State that are allowed by its type but make no sense, especially in the
case of Isabelle semantics where we use lists instead of maps:
\begin{enumerate}
\item The lists represent maps, so they should have no repeated keys.
\item We want two maps that are equal to be represented the same, so we force keys to be in ascending order.
\item We only want to record those accounts that contain a positive amount.
\end{enumerate}
We call a value for State valid if the first two properties are true. And we say it has positive
accounts if the third property is true.

\<close>
text \<open>FIXME: Address the review comment "Is this a note for us or the explanation to the user of what @{term playTraceAux_preserves_validAndPositive_state} proves?".\<close>

text \<open>@{thm playTraceAux_preserves_validAndPositive_state}\<close>

section \<open>Quiescent Result\<close>

text \<open>

A contract is quiescent if and only if the root construct is @{term When}, or if the contract is
@{term Close} and all accounts are empty. If an input @{term State} is valid and accounts are
positive, then the output will be quiescent, @{const isQuiescent}.
\<close>

text \<open>

The following always produce quiescent contracts:
\begin{itemize}
\item reductionLoop \secref{sec:reductionloop}
\item reduceContractUntilQuiescent \secref{sec:reduceContractUntilQuiescent}
\item applyAllInputs  \secref{sec:applyAllInputs}
\item computeTransaction  \secref{sec:computeTransaction}
\item playTrace  \secref{sec:playTrace}
\end{itemize}
\<close>

text \<open>@{thm playTraceIsQuiescent}\<close>

section \<open>Reducing a Contract until Quiescence Is Idempotent\<close>

text \<open>Once a contract is quiescent, further reduction will not change the contract or state,
and it will not produce any payments or warnings.\<close>

text \<open>@{thm reduceContractUntilQuiescentIdempotent}\<close>

section \<open>Split Transactions Into Single Input Does Not Affect the Result\<close>

text \<open>Applying a list of inputs to a contract produces the same result as applying each input
singly.\<close>

text \<open>@{thm playTraceAuxToSingleInputIsEquivalent }\<close>

subsection \<open>Termination Proof\<close>

text \<open>

Isabelle automatically proves termination for most function. However, this is not the case for
@{const reductionLoop}, but it is manually proved that the reduction loop monotonically reduces the
size of the contract (except for @{term Close}, which reduces the number of accounts), this is
sufficient to prove termination.

@{thm reduceContractStepReducesSize}

\<close>

subsection \<open>All Contracts Have a Maximum Time\<close>

text \<open>If one sends an empty transaction with time equal to @{const maxTimeContract}, then the
contract will close.\<close>

text \<open>@{thm [mode=Rule,names_short] timedOutTransaction_closes_contract}\<close>

subsection \<open>Contract Does Not Hold Funds After it Closes\<close>

text \<open>Funds are not held in a contract after it closes.\<close>

text \<open>@{thm closeIsSafe}\<close>

subsection \<open>Transaction Bound\<close>

text \<open>There is a maximum number of transaction that can be accepted by a contract.\<close>

(* should we have a maxTransactions :: Contract \<Rightarrow> Int in the semantics? *)

text \<open>@{thm playTrace_only_accepts_maxTransactionsInitialState}\<close>

(*<*)
end
(*>*)
