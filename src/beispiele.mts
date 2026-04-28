// Copyright (C) 2025 - present Juergen Zimmermann, Hochschule Karlsruhe
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

// Aufruf:  bun i
//          bun --env-file=.env prisma generate
//
//          bun --env-file=.env src\beispiele.mts

import process from 'node:process';
import { styleText } from 'node:util';
import { PrismaPg } from '@prisma/adapter-pg';
import { prismaQueryInsights } from '@prisma/sqlcommenter-query-insights';
import {
    PrismaClient,
    type Cafe,
    type Prisma,
} from './generated/prisma/client.ts';

let message = styleText(['black', 'bgWhite'], 'Node version');
console.log(`${message}=${process.version}`);
message = styleText(['black', 'bgWhite'], 'DATABASE_URL');
console.log(`${message}=${process.env['DATABASE_URL']}`);
console.log();

// "named parameter" durch JSON-Objekt
const adapter = new PrismaPg({
    connectionString: process.env['DATABASE_URL'],
});

// union type
const log: (Prisma.LogLevel | Prisma.LogDefinition)[] = [
    {
        // siehe unten: prisma.$on('query', ...);
        emit: 'event',
        level: 'query',
    },
    'info',
    'warn',
    'error',
];

// PrismaClient passend zur Umgebungsvariable DATABASE_URL in ".env"
// d.h. mit PostgreSQL-User "cafe" und Schema "cafe"
const prisma = new PrismaClient({
    // shorthand property
    adapter,
    errorFormat: 'pretty',
    log,
    // Kommentar zu Log-Ausgabe:
    // /*prismaQuery='Cafe.findMany%3A...
    comments: [prismaQueryInsights()],
});
prisma.$on('query', (e) => {
    message = styleText('green', `Query: ${e.query}`);
    console.log(message);
    message = styleText('cyan', `Duration: ${e.duration} ms`);
    console.log(message);
});

export type CafeMitManagerUndProdukten = Prisma.CafeGetPayload<{
    include: {
        cafeManager: true;
        produkte: true;
    };
}>;

// Operationen mit dem Model "Cafe"
try {
    await prisma.$connect();

    // Das Resultat ist null, falls kein Datensatz gefunden
    const cafe: Cafe | null = await prisma.cafe.findUnique({
        where: { id: 1 },
    });
    message = styleText(['black', 'bgWhite'], 'cafe');
    console.log(`${message} = %j`, cafe);
    console.log();

    // SELECT *
    // FROM   cafe
    // JOIN   cafe_manager ON cafe.id = cafe_manager.cafe_id
    // WHERE  cafe_manager.nachname LIKE "%n%"
    const cafes: CafeMitManagerUndProdukten[] = await prisma.cafe.findMany({
        where: {
            cafeManager: {
                // https://www.prisma.io/docs/orm/prisma-client/queries/filtering-and-sorting#filter-on-relations
                nachname: {
                    // https://www.prisma.io/docs/orm/reference/prisma-client-reference#filter-conditions-and-operators
                    contains: 'n',
                },
            },
        },
        // Fetch-Join mit CafeManager und Produkten
        include: {
            cafeManager: true,
            produkte: true,
        },
    });
    message = styleText(['black', 'bgWhite'], 'cafesMitProdukten');
    console.log(`${message} = %j`, cafes);
    console.log();

    // higher-order function und arrow function
    const kaffeesorten = cafes.map((c) => c.kaffeesorten);
    message = styleText(['black', 'bgWhite'], 'kaffeesorten');
    console.log(`${message} = %j`, kaffeesorten);
    console.log();

    // union type
    const nachnamen = cafes.map((c) => c.cafeManager?.nachname);
    message = styleText(['black', 'bgWhite'], 'nachnamen');
    console.log(`${message} = %j`, nachnamen);
    console.log();

    // Pagination
    const cafesPage2: Cafe[] = await prisma.cafe.findMany({
        skip: 5,
        take: 5,
    });
    message = styleText(['black', 'bgWhite'], 'cafesPage2');
    console.log(`${message} = %j`, cafesPage2);
    console.log();
} finally {
    await prisma.$disconnect();
}

// PrismaClient mit PostgreSQL-User "postgres", d.h. mit Administrationsrechten
const adapterAdmin = new PrismaPg({
    connectionString: process.env['DATABASE_URL_ADMIN'],
});
const prismaAdmin = new PrismaClient({ adapter: adapterAdmin });
try {
    const cafesAdmin: Cafe[] = await prismaAdmin.cafe.findMany({
        where: {
            cafeManager: {
                nachname: {
                    contains: 'n',
                },
            },
        },
    });
    message = styleText(['black', 'bgWhite'], 'cafesAdmin');
    console.log(`${message} = ${JSON.stringify(cafesAdmin)}`);
} finally {
    await prismaAdmin.$disconnect();
}
