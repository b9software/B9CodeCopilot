import { getAppUrl } from "@roo-code/types"

const getKiloCodeSource = (uriScheme: string = "vscode") => {
	return uriScheme
}

export function getKiloCodeBackendSignInUrl(uriScheme: string = "vscode", uiKind: string = "Desktop") {
	const source = uiKind === "Web" ? "web" : getKiloCodeSource(uriScheme)
	return getAppUrl(`/sign-in-to-editor?source=${source}`)
}

export function getKiloCodeBackendSignUpUrl(uriScheme: string = "vscode", uiKind: string = "Desktop") {
	const source = uiKind === "Web" ? "web" : getKiloCodeSource(uriScheme)
	return getAppUrl(`/users/sign_up?source=${source}`)
}
