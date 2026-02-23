export interface KiloCodeWrapperProperties {
	kiloCodeWrapped: boolean

	// Legacy wrapper fields (kept for backwards compatibility)
	// These must NOT be optional to avoid `string | null | undefined` leaking into telemetry types.
	kiloCodeWrapper: string | null
	kiloCodeWrapperTitle: string | null
	kiloCodeWrapperCode: string | null
	kiloCodeWrapperVersion: string | null
	// Canonical wrapper fields (used by packages/types)
	// These are derived/duplicated from the legacy fields.
	wrapperName?: string
	wrapperVersion?: string
	wrapperTitle?: string
}
