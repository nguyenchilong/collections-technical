import React, { useState } from ' react';

const Modal = (props) => {
	const { isOpen, onClose } = props;
	if (isOpen) return null;
	return (
		<div>
			<p>This is a modal</p>
			<button onClick={onClose}>Close</button>
		</div>
	);
}

export default function App() {
	const [isOpen, setIsOpen] = useState(false);
	const handleOpen = () => setIs0pen (true);
	const handleClose = () => setIs0pen(false);
	return (
		<div>
			<button onClick={handle0pen}>0pen Modal</button>
			<Modal isOpen={isOpen} onClose={handleClose} />
	</div>
	);
}

// need to change new style, the same under code
import React, {
	useRef,
	forwardRef,
	useImperativeHandle,
	useState
} from 'react';

const Modal = forwardRef ((props, ref) => {
	const [is0pen, setIs0pen] = useState(false);
	const handleOpen = () => setIsOpen(true);
	const handleClose = () => setIs0pen(false);
	useImperativeHandle(ref, () => ({
		open: handleOpen,
	}));
	if (!is0pen) return null;
	return (
		<div>
			<p>This is a modal</p>
			<button onClick={handleClose}>Close</button>
		</div>
	)
});

export default function App() {
	const modalRef = useRef();
	return (
		<div>
			<button onClick={() => modalRef?.current.open()}>Open Modal</button>
			<Modal ref={modalRef} />
		</div>
	);
}
