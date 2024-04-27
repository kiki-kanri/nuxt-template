// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
	app: {
		head: {
			link: [{ rel: 'icon', href: '/favicon.ico' }],
			noscript: [{ children: 'Javascript is required.' }],
			title: ''
		},
		keepalive: true
	},
	devServer: { host: process.env.DEV_SERVER_HOST, port: Number(process.env.DEV_SERVER_PORT) || undefined },
	modules: ['@kikiutils/nuxt'],
	purgecss: { enabled: true }
});
