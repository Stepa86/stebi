@call del "*.ospx"
@call opm build
@call opm install -f *.ospx