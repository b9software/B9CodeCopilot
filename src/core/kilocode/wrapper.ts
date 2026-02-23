import * as vscode from "vscode"
import { KiloCodeWrapperProperties } from "../../shared/kilocode/wrapper"
import { TelemetrySetting } from "@roo-code/types"

export const getKiloCodeWrapperProperties = (): KiloCodeWrapperProperties => {
	const appName = vscode.env.appName
	const kiloCodeWrapped = appName.includes("wrapper")
	let kiloCodeWrapper = null
	let kiloCodeWrapperTitle = null
	let kiloCodeWrapperCode = null
	let kiloCodeWrapperVersion = null

	if (kiloCodeWrapped) {
		const wrapperMatch = appName.split("|")
		kiloCodeWrapper = wrapperMatch[1].trim() || null
		kiloCodeWrapperCode = wrapperMatch[2].trim() || null
		kiloCodeWrapperVersion = wrapperMatch[3].trim() || null
		kiloCodeWrapperTitle = kiloCodeWrapperCode === "cli" ? "Kilo Code CLI" : kiloCodeWrapperCode || "Wrapper"
	}

	return {
		kiloCodeWrapped,
		kiloCodeWrapper,
		kiloCodeWrapperTitle,
		kiloCodeWrapperCode,
		kiloCodeWrapperVersion,
	}
}

export const getEditorNameHeader = () => {
	const props = getKiloCodeWrapperProperties()
	return (
		props.kiloCodeWrapped
			? [props.kiloCodeWrapperTitle, props.kiloCodeWrapperVersion]
			: [vscode.env.appName, vscode.version]
	)
		.filter(Boolean)
		.join(" ")
}

export function getEffectiveTelemetrySetting(telemetrySetting: TelemetrySetting | undefined) {
	const isVsCode = !getKiloCodeWrapperProperties().kiloCodeWrapped
	return isVsCode && vscode.env.isTelemetryEnabled
		? "enabled"
		: telemetrySetting === "disabled"
			? "disabled"
			: "enabled"
}
