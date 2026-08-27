-- nvim/lua/snippets/tex.lua

local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node

local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		{
			trig = "fig",
			name = "figure",
			dscr = "Insert a LaTeX figure environment",
		},
		fmt(
			[[
\begin{figure}[<>]
  \centering
  \includegraphics[width=\linewidth]{<>}
  \caption{<>}
  \label{fig:<>}
\end{figure}
]],
			{
				i(1, "htbp"),
				i(2, "img/"),
				i(3, "caption"),
			},
			{
				delimiters = "<>",
			}
		)
	),
}
