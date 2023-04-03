import React, { useState, useEffect } from 'react';
import { defaultAppState } from './config';
import Body from './core/Body';
import store from './store';

import { createTheme } from '@mui/material/styles';
import { ThemeProvider } from '@mui/material';
import blue from '@mui/material/colors/blue';
import pink from '@mui/material/colors/pink';
import red from '@mui/material/colors/red';

import './app.scss';

/**
 * Material UI Theme
 */
let theme = createTheme({
	palette: {
		type: 'light',
		primary: blue,
		secondary: pink,
		error: red,
		tonalOffset: 0.2,
	},
	typography: {
		useNextVariants: true,
	},
});

/**
 * @function App
 * @description Root application component
 */
export default function App() {
	// Setup our default state
	let [state, setState] = useState(defaultAppState);

	// Use this hook to run on mount and unmount only
	useEffect(() => {
		// Subscribe to state changes
		let unsubscribe = store.subscribe(() => setState(store.getState()));

		// Unsubscribe before unmount
		return unsubscribe;
	}, []);

	return (
		<ThemeProvider theme={theme}>
			<header className="header">Default Settings</header>
			<Body {...state} />
			<footer className="footer">Default Settings</footer>
		</ThemeProvider>
	);
}
