import React from 'react';

function TextHighlighter({ text = "", highlight = "" }) {
	if (!highlight.trim()) return <span>{text}</span>;
	const regex = new RegExp(`(${highlight})`, "gi");
	const parts = text.split(regex);

	return (
		<div>
			{parts ? (
				parts
					.filter(String)
					.map((part, i) =>
						regex.test(part) ? (
							<b data-search-highlighter-bold key={i}>{part}</b>
						) : (
							<span key={i}>{part}</span>
						)
					)
			) : (
				<span>{text}</span>
			)}
		</div>
	);
}

export default TextHighlighter;


// Useage
// <TextHighlighter text="Aamir Amin" highlight="Aamir" />

