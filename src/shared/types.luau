-- v1.6 shared types: the shapes the karaoke queue, seats and interaction
-- prompts pass between server and client.

export type QueueSong = {
	userId: number,
	userName: string,
	songTitle: string,
	queuedAt: number,
}

export type KaraokeState = {
	current: QueueSong?,
	queue: { QueueSong },
}

export type SeatData = {
	seat: Seat,
	occupied: boolean,
	occupant: Player?,
}

export type InteractionTarget = {
	part: BasePart,
	actionText: string,
	kind: string,
}

return nil
