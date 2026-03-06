# Git - Referencia completa

## Configuracion inicial

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
git config --global core.editor vim
git config --global init.defaultBranch main

# Ver configuracion
git config --list
git config --global --list
```

---

## Operaciones basicas

```bash
# Iniciar repo
git init
git clone <url>
git clone <url> <nombre-carpeta>
git clone --depth=1 <url>      # solo el ultimo commit (mas rapido)

# Estado y diferencias
git status
git diff                        # cambios no staged
git diff --staged               # cambios staged
git diff main..feature          # diferencia entre ramas

# Staging y commit
git add .
git add archivo.txt
git add -p                      # agregar por bloques interactivo (muy util)
git commit -m "mensaje"
git commit -am "mensaje"        # add + commit en archivos tracked
git commit --amend              # modificar el ultimo commit (antes de push)
git commit --amend --no-edit    # agregar cambios al ultimo commit sin cambiar mensaje
```

---

## Branches

```bash
# Crear y cambiar
git branch nombre
git checkout nombre
git checkout -b nombre          # crear y cambiar en un paso
git switch nombre               # moderno
git switch -c nombre            # crear y cambiar (moderno)

# Listar
git branch                      # ramas locales
git branch -r                   # ramas remotas
git branch -a                   # todas

# Renombrar
git branch -m nombre-viejo nombre-nuevo
git branch -m nuevo-nombre      # renombrar la rama actual

# Eliminar
git branch -d nombre            # solo si ya esta mergeada
git branch -D nombre            # forzar (aunque no este mergeada)
git push origin --delete nombre # eliminar rama remota

# Ver cual fue el ultimo commit de cada rama
git branch -v
git branch -vv                  # incluyendo tracking remoto
```

---

## Remote y sincronizacion

```bash
# Ver remotos
git remote -v
git remote add origin <url>
git remote remove origin
git remote rename origin upstream

# Fetch vs Pull
git fetch                       # bajar cambios sin hacer merge
git fetch --all                 # bajar de todos los remotos
git pull                        # fetch + merge
git pull --rebase               # fetch + rebase (historial mas limpio)

# Push
git push origin nombre-rama
git push -u origin nombre-rama  # primera vez: configura tracking
git push --force-with-lease     # force push seguro (falla si alguien pusheo)
git push --force                # force push (destructivo, cuidado)
git push --tags                 # subir tags
```

---

## Merge y Rebase

```bash
# Merge
git merge feature-branch        # merge de feature-branch en la rama actual
git merge --no-ff feature-branch # forzar merge commit (no fast-forward)
git merge --squash feature-branch # squash todos los commits en uno
git merge --abort               # cancelar merge en conflicto

# Rebase
git rebase main                 # rebase de la rama actual sobre main
git rebase -i HEAD~3            # rebase interactivo de los ultimos 3 commits
git rebase --onto main feature-base feature-nueva
git rebase --abort              # cancelar rebase
git rebase --continue           # continuar despues de resolver conflicto

# En rebase interactivo (opciones):
# pick   - usar el commit tal cual
# reword - usar el commit pero cambiar el mensaje
# edit   - pausar para editar el commit
# squash - combinar con el commit anterior (mantiene mensajes)
# fixup  - combinar con el anterior (descarta el mensaje)
# drop   - eliminar el commit
```

---

## Deshacer cambios

```bash
# Deshacer cambios no staged
git restore archivo.txt         # restaurar archivo al ultimo commit
git restore .                   # restaurar todo
git checkout -- archivo.txt     # equivalente (forma antigua)

# Deshacer cambios staged
git restore --staged archivo.txt
git reset HEAD archivo.txt      # equivalente

# Deshacer commits (sin perder cambios)
git reset --soft HEAD~1         # quita el ultimo commit, cambios quedan staged
git reset --soft HEAD~3         # quita los ultimos 3 commits, cambios quedan staged
git reset HEAD~1                # (--mixed por defecto) quita commit, cambios quedan unstaged

# Deshacer commits (destruye los cambios)
git reset --hard HEAD~1         # peligroso: borra el ultimo commit Y los cambios

# Revertir un commit ya pusheado (crea un commit nuevo que deshace)
git revert <hash>
git revert HEAD                 # revertir el ultimo commit

# Limpiar archivos no rastreados
git clean -n                    # dry-run: ver que se borraria
git clean -fd                   # borrar archivos y directorios no tracked
git clean -fdx                  # incluye archivos ignorados por .gitignore
```

---

## Stash

```bash
# Guardar cambios temporalmente
git stash
git stash save "nombre descriptivo"
git stash push -m "nombre" archivo.txt   # stash de un archivo especifico

# Ver stashes
git stash list

# Recuperar stash
git stash pop                   # aplica el ultimo y lo elimina del stash
git stash apply                 # aplica el ultimo sin eliminarlo
git stash apply stash@{2}       # aplicar stash especifico

# Eliminar stash
git stash drop stash@{0}
git stash clear                 # eliminar todos los stashes

# Ver contenido de un stash
git stash show -p stash@{0}

# Crear rama desde un stash
git stash branch nueva-rama stash@{0}
```

---

## Cherry-pick

```bash
# Traer un commit especifico a la rama actual
git cherry-pick <hash>

# Traer varios commits
git cherry-pick <hash1> <hash2>

# Traer un rango de commits
git cherry-pick <hash-inicio>..<hash-final>

# Cherry-pick sin hacer commit automatico
git cherry-pick --no-commit <hash>

# Abortar
git cherry-pick --abort
```

---

## Tags

```bash
# Crear tag
git tag v1.0.0                          # tag ligero
git tag -a v1.0.0 -m "Release v1.0.0"  # tag anotado (recomendado)
git tag -a v1.0.0 <hash>               # taggear un commit especifico

# Ver tags
git tag
git tag -l "v1.*"                       # filtrar
git show v1.0.0

# Subir tags
git push origin v1.0.0
git push origin --tags                  # subir todos los tags

# Eliminar tag
git tag -d v1.0.0                       # local
git push origin --delete v1.0.0         # remoto
```

---

## Log y busqueda

```bash
# Ver historial
git log
git log --oneline
git log --oneline --graph --all         # grafo de ramas
git log --oneline -10                   # ultimos 10
git log --author="Lucas"
git log --grep="fix:"                   # buscar en mensajes
git log --since="2024-01-01"
git log --until="2024-12-31"
git log -- archivo.txt                  # historial de un archivo
git log main..feature                   # commits de feature que no estan en main

# Ver quien cambio que linea
git blame archivo.txt
git blame -L 10,20 archivo.txt          # solo lineas 10-20

# Buscar en el contenido de commits
git log -S "texto buscado"              # commits que agregaron/quitaron texto
git log -G "regex"                      # por regex

# Ver un commit especifico
git show <hash>
git show <hash>:archivo.txt             # ver archivo en ese commit
```

---

## Worktrees (multiples copias del repo)

```bash
# Crear worktree en otra carpeta con una rama
git worktree add ../mi-app-feature feature-branch

# Listar worktrees
git worktree list

# Eliminar worktree
git worktree remove ../mi-app-feature

# Crear worktree con rama nueva
git worktree add -b nueva-rama ../carpeta origin/main
```

---

## Bisect (encontrar cuando se introdujo un bug)

```bash
# Iniciar bisect
git bisect start

# Marcar el commit actual como malo
git bisect bad

# Marcar el ultimo commit bueno conocido
git bisect good v1.0.0

# Git va a hacer checkout en el medio del rango
# Probar si el bug existe y marcar:
git bisect good     # si este commit esta bien
git bisect bad      # si el bug esta presente

# Cuando bisect encuentre el commit culpable, resetear
git bisect reset
```

---

## Gitflow - Convenciones de ramas

```
main          - produccion (siempre deployable)
develop       - integracion (base para features)
feature/xxx   - nuevas funcionalidades
hotfix/xxx    - correcciones urgentes en produccion
release/x.x.x - preparacion de release
```

## Conventional Commits

```
feat:     nueva funcionalidad
fix:      correccion de bug
docs:     documentacion
style:    formato, sin cambios de logica
refactor: refactorizacion
test:     agregar o modificar tests
chore:    tareas de mantenimiento, CI, etc.
ci:       cambios en CI/CD
build:    cambios en build system o dependencias

# Ejemplos
feat(auth): agregar login con Google
fix(api): corregir error 500 en endpoint /users
docs: actualizar README con instrucciones de instalacion
ci: agregar workflow de deploy a staging
```

---

## .gitignore - Patrones comunes

```gitignore
# Dependencias
node_modules/
vendor/
.venv/

# Builds
dist/
build/
*.pyc
*.class
*.jar

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Secretos (NUNCA commitear)
.env
.env.*
*.pem
*.key
secrets.yml
terraform.tfvars

# Logs
*.log
logs/
```

---

## Comandos para resolver conflictos

```bash
# Ver archivos en conflicto
git status

# Abrir herramienta de merge visual
git mergetool

# Despues de resolver manualmente
git add archivo-resuelto.txt
git merge --continue
# o
git rebase --continue

# Aceptar todo "el nuestro" o "el de ellos"
git checkout --ours archivo.txt
git checkout --theirs archivo.txt
```
